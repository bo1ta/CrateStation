defmodule CrateStation.Discogs.Releases do
  @moduledoc """
  Cache boundary for Discogs release data.
  """

  alias CrateStation.Discogs.Release
  alias CrateStation.Repo

  def get_release(discogs_id) when is_integer(discogs_id) do
    Repo.get_by(Release, discogs_id: discogs_id)
  end

  def get_or_fetch_release(discogs_id) when is_integer(discogs_id) do
    case get_release(discogs_id) do
      %Release{} = release -> {:ok, release}
      nil -> fetch_and_cache_release(discogs_id)
    end
  end

  def fetch_and_cache_release(discogs_id) when is_integer(discogs_id) do
    with {:ok, %ExDisco.Releases.Release{} = release} <- ExDisco.Releases.get_release(discogs_id) do
      cache_release(release)
    end
  end

  def cache_release(%ExDisco.Releases.Release{} = release) do
    attrs = from_ex_disco(release)

    %Release{}
    |> Release.changeset(attrs)
    |> Repo.insert(
      conflict_target: :discogs_id,
      on_conflict:
        {:replace,
         [
           :master_id,
           :title,
           :status,
           :country,
           :notes,
           :released,
           :released_formatted,
           :resource_url,
           :uri,
           :thumb,
           :master_url,
           :data_quality,
           :lowest_price,
           :num_for_sale,
           :estimated_weight,
           :format_quantity,
           :year,
           :date_added,
           :date_changed,
           :genres,
           :styles,
           :series,
           :artist_ids,
           :label_ids,
           :artists,
           :extraartists,
           :companies,
           :formats,
           :identifiers,
           :images,
           :labels,
           :tracklist,
           :videos,
           :community,
           :fetched_at,
           :last_refresh_error,
           :updated_at
         ]},
      returning: true
    )
  end

  def from_ex_disco(%ExDisco.Releases.Release{} = release) do
    artists = Enum.map(release.artists, &artist_credit_attrs/1)
    labels = Enum.map(release.labels, &credit_entity_attrs/1)

    %{
      discogs_id: release.id,
      master_id: release.master_id,
      title: release.title,
      status: release.status,
      country: release.country,
      notes: release.notes,
      released: release.released,
      released_formatted: release.released_formatted,
      resource_url: release.resource_url,
      uri: release.uri,
      thumb: release.thumb,
      master_url: release.master_url,
      data_quality: release.data_quality,
      lowest_price: release.lowest_price,
      num_for_sale: release.num_for_sale,
      estimated_weight: release.estimated_weight,
      format_quantity: release.format_quantity,
      year: release.year,
      date_added: release.date_added,
      date_changed: release.date_changed,
      genres: release.genres || [],
      styles: release.styles || [],
      series: release.series || [],
      artist_ids: discogs_ids(artists),
      label_ids: discogs_ids(labels),
      artists: artists,
      extraartists: Enum.map(release.extraartists, &artist_credit_attrs/1),
      companies: Enum.map(release.companies, &credit_entity_attrs/1),
      formats: Enum.map(release.formats, &format_attrs/1),
      identifiers: Enum.map(release.identifiers, &identifier_attrs/1),
      images: Enum.map(release.images, &image_attrs/1),
      labels: labels,
      tracklist: Enum.map(release.tracklist, &track_attrs/1),
      videos: Enum.map(release.videos, &video_attrs/1),
      community: community_attrs(release.community),
      fetched_at: DateTime.utc_now(:second),
      last_refresh_error: nil
    }
  end

  defp discogs_ids(entries) do
    entries
    |> Enum.map(& &1.discogs_id)
    |> Enum.reject(&is_nil/1)
  end

  defp artist_credit_attrs(credit) do
    %{
      discogs_id: credit.id,
      name: credit.name,
      anv: credit.anv,
      role: credit.role,
      join: credit.join,
      tracks: credit.tracks,
      resource_url: credit.resource_url
    }
  end

  defp credit_entity_attrs(entity) do
    %{
      discogs_id: entity.id,
      name: entity.name,
      catno: entity.catno,
      entity_type: entity.entity_type,
      entity_type_name: entity.entity_type_name,
      resource_url: entity.resource_url
    }
  end

  defp format_attrs(format) do
    %{
      name: format.name,
      qty: format.qty,
      descriptions: format.descriptions || []
    }
  end

  defp identifier_attrs(identifier) do
    %{
      type: Map.get(identifier, :type) || Map.get(identifier, "type"),
      value: Map.get(identifier, :value) || Map.get(identifier, "value")
    }
  end

  defp image_attrs(image) do
    %{
      uri: image.uri,
      uri150: image.uri150,
      resource_url: image.resource_url,
      type: image.type,
      width: image.width,
      height: image.height
    }
  end

  defp track_attrs(track) do
    %{
      title: track.title,
      position: track.position,
      duration: track.duration,
      type: track.type
    }
  end

  defp video_attrs(video) do
    %{
      uri: video.uri,
      title: video.title,
      description: video.description,
      duration: video.duration,
      embed: video.embed
    }
  end

  defp community_attrs(nil), do: nil

  defp community_attrs(community) do
    %{
      have: community.have,
      want: community.want,
      status: community.status,
      data_quality: community.data_quality,
      rating_average: community.rating_average,
      rating_count: community.rating_count,
      submitter: community.submitter
    }
  end
end
