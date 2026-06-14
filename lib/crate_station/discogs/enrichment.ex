defmodule CrateStation.Discogs.Enrichment do
  @moduledoc """
  Matches local tracks to Discogs release tracklist entries.
  """

  alias CrateStation.Discogs.{Releases, TrackMatch}
  alias CrateStation.Music
  alias CrateStation.Music.Track
  alias CrateStation.Repo
  alias ExDisco.Search

  @candidate_limit 12
  @search_page_size 25
  @matched_threshold 0.78
  @minimum_score 0.45
  @ambiguous_delta 0.05

  @upsert_fields [
    :status,
    :discogs_release_id,
    :discogs_master_id,
    :discogs_track_position,
    :discogs_track_title,
    :discogs_artist_ids,
    :discogs_label_ids,
    :confidence_score,
    :match_strategy,
    :match_evidence,
    :last_attempted_at,
    :matched_at,
    :attempt_count,
    :last_error,
    :updated_at
  ]

  def enrich_track(track_id) when is_integer(track_id) do
    with %Track{} = track <- Music.get_preloaded_track(track_id) do
      track
      |> search_candidates()
      |> case do
        {:ok, candidates, search_evidence} ->
          enrich_from_candidates(track, candidates, search_evidence)

        {:error, reason} ->
          persist_failed(track, reason)
      end
    else
      nil -> {:error, :track_not_found}
    end
  end

  defp enrich_from_candidates(%Track{} = track, candidates, search_evidence) do
    scored_candidates =
      candidates
      |> Enum.map(&candidate_release_id/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()
      |> Enum.flat_map(fn release_id ->
        case Releases.get_or_fetch_release(release_id) do
          {:ok, release} -> [score_release(track, release)]
          {:error, _reason} -> []
        end
      end)
      |> Enum.sort_by(& &1.score, :desc)

    persist_result(track, scored_candidates, search_evidence)
  end

  defp search_candidates(%Track{} = track) do
    track
    |> search_queries()
    |> Enum.reduce_while({:ok, [], []}, fn filters, {:ok, _items, attempts} ->
      case Search.query(filters) do
        {:ok, page} ->
          attempt = %{filters: Map.new(filters), total: page.total, count: length(page.items)}

          case page.items do
            [] ->
              {:cont, {:ok, [], [attempt | attempts]}}

            items ->
              {:halt,
               {:ok, Enum.take(items, @candidate_limit), Enum.reverse([attempt | attempts])}}
          end

        {:error, reason} ->
          {:halt, {:error, reason}}
      end
    end)
  end

  defp search_queries(%Track{} = track) do
    [
      release_query(
        artist: artist_name(track),
        title: album_title(track),
        track: track.title,
        year: usable_year(track.year)
      ),
      release_query(artist: artist_name(track), title: album_title(track), track: track.title),
      release_query(
        q: joined_query([artist_name(track), album_title(track), track.title]),
        year: usable_year(track.year)
      ),
      release_query(q: joined_query([artist_name(track), album_title(track), track.title])),
      release_query(q: joined_query([artist_name(track), track.title])),
      release_query(q: track.title)
    ]
    |> Enum.uniq()
  end

  defp release_query(filters) do
    [type: :release, per_page: @search_page_size]
    |> Keyword.merge(filters)
    |> Enum.reject(fn {_key, value} -> empty_filter?(value) end)
  end

  defp candidate_release_id(%{"id" => id}) when is_integer(id), do: id
  defp candidate_release_id(%{id: id}) when is_integer(id), do: id
  defp candidate_release_id(_candidate), do: nil

  defp score_release(%Track{} = track, release) do
    release.tracklist
    |> Enum.map(fn discogs_track ->
      score = score_track_match(track, release, discogs_track)

      %{
        release: release,
        discogs_track: discogs_track,
        score: score,
        evidence: evidence(track, release, discogs_track, score)
      }
    end)
    |> Enum.max_by(& &1.score, fn ->
      score = score_release_only(track, release)

      %{
        release: release,
        discogs_track: nil,
        score: score,
        evidence: evidence(track, release, nil, score)
      }
    end)
  end

  defp score_track_match(%Track{} = track, release, discogs_track) do
    weighted_score([
      {0.25, similarity(artist_name(track), release_artist_names(release)),
       present?(artist_name(track))},
      {0.25, similarity(album_title(track), release.title), present?(album_title(track))},
      {0.35, similarity(track.title, discogs_track.title), true},
      {0.10, duration_similarity(track.duration, discogs_track.duration),
       present?(track.duration) and present?(parse_duration(discogs_track.duration))},
      {0.05, year_similarity(usable_year(track.year), release.year),
       present?(usable_year(track.year))}
    ])
  end

  defp score_release_only(%Track{} = track, release) do
    weighted_score([
      {0.35, similarity(artist_name(track), release_artist_names(release)),
       present?(artist_name(track))},
      {0.35, similarity(album_title(track), release.title), present?(album_title(track))},
      {0.20, similarity(track.title, release.title), true},
      {0.10, year_similarity(usable_year(track.year), release.year),
       present?(usable_year(track.year))}
    ])
  end

  defp persist_result(%Track{} = track, [], search_evidence),
    do: persist_not_found(track, [], search_evidence)

  defp persist_result(%Track{} = track, [best | rest] = scored_candidates, search_evidence) do
    second = List.first(rest)

    attrs =
      cond do
        best.score < @minimum_score ->
          not_found_attrs(scored_candidates, search_evidence)

        second && best.score - second.score <= @ambiguous_delta ->
          ambiguous_attrs(best, scored_candidates, search_evidence)

        best.score >= @matched_threshold ->
          matched_attrs(best, search_evidence)

        true ->
          ambiguous_attrs(best, scored_candidates, search_evidence)
      end

    upsert_track_match(track, attrs)
  end

  defp persist_not_found(%Track{} = track, scored_candidates, search_evidence) do
    upsert_track_match(track, not_found_attrs(scored_candidates, search_evidence))
  end

  defp persist_failed(%Track{} = track, reason) do
    upsert_track_match(track, %{
      status: :failed,
      confidence_score: nil,
      match_strategy: nil,
      match_evidence: %{},
      last_attempted_at: now(),
      matched_at: nil,
      last_error: inspect(reason)
    })
  end

  defp matched_attrs(best, search_evidence) do
    %{
      status: :matched,
      discogs_release_id: best.release.discogs_id,
      discogs_master_id: best.release.master_id,
      discogs_track_position: best.discogs_track && best.discogs_track.position,
      discogs_track_title: best.discogs_track && best.discogs_track.title,
      discogs_artist_ids: best.release.artist_ids,
      discogs_label_ids: best.release.label_ids,
      confidence_score: best.score,
      match_strategy: :fuzzy_title,
      match_evidence: Map.put(best.evidence, :searches, search_evidence),
      matched_at: now(),
      last_attempted_at: now(),
      last_error: nil
    }
  end

  defp ambiguous_attrs(best, scored_candidates, search_evidence) do
    match_evidence =
      best.evidence
      |> Map.put(:candidates, candidate_evidence(scored_candidates))
      |> Map.put(:searches, search_evidence)

    best
    |> matched_attrs(search_evidence)
    |> Map.merge(%{
      status: :ambiguous,
      matched_at: nil,
      match_evidence: match_evidence
    })
  end

  defp not_found_attrs(scored_candidates, search_evidence) do
    %{
      status: :not_found,
      discogs_release_id: nil,
      discogs_master_id: nil,
      discogs_track_position: nil,
      discogs_track_title: nil,
      discogs_artist_ids: [],
      discogs_label_ids: [],
      confidence_score: nil,
      match_strategy: nil,
      match_evidence: %{
        candidates: candidate_evidence(scored_candidates),
        searches: search_evidence
      },
      matched_at: nil,
      last_attempted_at: now(),
      last_error: nil
    }
  end

  defp upsert_track_match(%Track{} = track, attrs) do
    attrs =
      attrs
      |> Map.put(:user_id, track.user_id)
      |> Map.put(:track_id, track.id)
      |> Map.put(:attempt_count, attempt_count(track))

    %TrackMatch{}
    |> TrackMatch.changeset(attrs)
    |> Repo.insert(
      conflict_target: [:user_id, :track_id],
      on_conflict: {:replace, @upsert_fields},
      returning: true
    )
  end

  defp attempt_count(%Track{discogs_track_match: %TrackMatch{attempt_count: count}})
       when is_integer(count),
       do: count + 1

  defp attempt_count(_track), do: 1

  defp evidence(%Track{} = track, release, discogs_track, score) do
    %{
      score: score,
      local: %{
        title: track.title,
        artist: artist_name(track),
        album: album_title(track),
        duration: track.duration,
        year: usable_year(track.year)
      },
      discogs: %{
        release_id: release.discogs_id,
        release_title: release.title,
        artist_names: release_artist_names(release),
        track_title: discogs_track && discogs_track.title,
        track_position: discogs_track && discogs_track.position,
        track_duration: discogs_track && discogs_track.duration,
        year: release.year
      }
    }
  end

  defp candidate_evidence(scored_candidates) do
    Enum.map(scored_candidates, fn candidate ->
      %{
        release_id: candidate.release.discogs_id,
        release_title: candidate.release.title,
        track_title: candidate.discogs_track && candidate.discogs_track.title,
        track_position: candidate.discogs_track && candidate.discogs_track.position,
        score: candidate.score
      }
    end)
  end

  defp release_artist_names(release) do
    Enum.map(release.artists, & &1.name)
  end

  defp artist_name(%Track{artist: %{name: name}}) when is_binary(name), do: name
  defp artist_name(_track), do: nil

  defp album_title(%Track{album: %{title: title}}) when is_binary(title), do: title
  defp album_title(_track), do: nil

  defp usable_year(year) when is_integer(year) and year > 0, do: year
  defp usable_year(_year), do: nil

  defp joined_query(values) do
    values
    |> Enum.reject(&empty_filter?/1)
    |> Enum.join(" ")
  end

  defp empty_filter?(nil), do: true
  defp empty_filter?(""), do: true
  defp empty_filter?(0), do: true
  defp empty_filter?(_value), do: false

  defp present?(nil), do: false
  defp present?(""), do: false
  defp present?(0), do: false
  defp present?([]), do: false
  defp present?(_value), do: true

  defp weighted_score(components) do
    available_components =
      Enum.filter(components, fn {_weight, _score, available?} -> available? end)

    total_weight =
      Enum.reduce(available_components, 0.0, fn {weight, _score, _available?}, total ->
        total + weight
      end)

    if total_weight == 0.0 do
      0.0
    else
      Enum.reduce(available_components, 0.0, fn {weight, score, _available?}, total ->
        total + weight / total_weight * score
      end)
    end
  end

  defp similarity(nil, _right), do: 0.0
  defp similarity(_left, nil), do: 0.0

  defp similarity(left, right) when is_list(right) do
    right
    |> Enum.map(&similarity(left, &1))
    |> Enum.max(fn -> 0.0 end)
  end

  defp similarity(left, right) when is_binary(left) and is_binary(right) do
    left = normalize(left)
    right = normalize(right)

    cond do
      left == "" or right == "" -> 0.0
      left == right -> 1.0
      String.contains?(left, right) or String.contains?(right, left) -> 0.92
      true -> String.jaro_distance(left, right)
    end
  end

  defp normalize(value) do
    value
    |> String.downcase()
    |> String.replace(~r/[\p{P}\p{S}]+/u, " ")
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end

  defp duration_similarity(nil, _duration), do: 0.0
  defp duration_similarity(_duration, nil), do: 0.0

  defp duration_similarity(local_seconds, discogs_duration) when is_integer(local_seconds) do
    case parse_duration(discogs_duration) do
      nil ->
        0.0

      discogs_seconds ->
        diff = abs(local_seconds - discogs_seconds)
        max(0.0, 1.0 - diff / 30)
    end
  end

  defp parse_duration(duration) when is_binary(duration) do
    parts =
      duration
      |> String.split(":")
      |> Enum.map(&Integer.parse/1)

    if Enum.all?(parts, &match?({_, ""}, &1)) do
      parts
      |> Enum.map(fn {part, ""} -> part end)
      |> Enum.reduce(0, fn part, acc -> acc * 60 + part end)
    end
  end

  defp parse_duration(_duration), do: nil

  defp year_similarity(nil, _year), do: 0.0
  defp year_similarity(_year, nil), do: 0.0
  defp year_similarity(year, year), do: 1.0

  defp year_similarity(left, right) when is_integer(left) and is_integer(right) do
    diff = abs(left - right)
    max(0.0, 1.0 - diff / 5)
  end

  defp now, do: DateTime.utc_now(:second)
end
