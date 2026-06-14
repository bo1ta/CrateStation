defmodule CrateStation.Sync.BulkImporter do
  import Ecto.Query, warn: false
  alias CrateStation.Repo

  alias CrateStation.Playback.PlaybackEvent
  alias CrateStation.Sync.{Parsers, Payloads}
  alias CrateStation.{Playlists, Music}

  alias CrateStation.Accounts.Scope
  alias CrateStation.Music.{Album, Track, Artist}
  alias CrateStation.Playlists.{Playlist, PlaylistTrack}

  def upsert_artists(%Scope{} = scope, attrs) when is_list(attrs) do
    now = DateTime.utc_now(:second)

    entries =
      Enum.map(
        attrs,
        &Payloads.artist_entry(&1, now: now, user_id: scope.user.id)
      )

    Repo.insert_all(Artist, entries,
      conflict_target: [:user_id, :client_id],
      on_conflict: {:replace, [:name, :slug, :updated_at]}
    )
  end

  def upsert_albums(%Scope{} = scope, attrs) when is_list(attrs) do
    now = DateTime.utc_now(:second)

    artist_id_by_client_id = client_id_to_artist_id(attrs, scope)

    entries =
      Enum.map(attrs, fn attr ->
        attr
        |> put_mapped_id("artist_client_id", "artist_id", artist_id_by_client_id)
        |> Payloads.album_entry(
          now: now,
          user_id: scope.user.id
        )
      end)

    Repo.insert_all(Album, entries,
      conflict_target: [:user_id, :client_id],
      on_conflict: {:replace, [:title, :year, :genre, :artist_id, :updated_at]}
    )
  end

  def upsert_tracks(%Scope{} = scope, attrs) when is_list(attrs) do
    now = DateTime.utc_now(:second)

    artist_id_by_client_id = client_id_to_artist_id(attrs, scope)
    album_id_by_client_id = client_id_to_album_id(attrs, scope)

    entries =
      Enum.map(attrs, fn attr ->
        attr
        |> put_mapped_id("artist_client_id", "artist_id", artist_id_by_client_id)
        |> put_mapped_id("album_client_id", "album_id", album_id_by_client_id)
        |> Payloads.track_entry(user_id: scope.user.id, now: now)
      end)

    Repo.insert_all(Track, entries,
      conflict_target: [:user_id, :client_id],
      on_conflict:
        {:replace,
         [
           :title,
           :duration,
           :track_number,
           :disc_number,
           :year,
           :genre,
           :bpm,
           :song_key,
           :play_count,
           :album_id,
           :rating,
           :is_favorite,
           :last_played_at,
           :imported_at,
           :artist_id,
           :updated_at
         ]}
    )
  end

  def upsert_playlists(%Scope{} = scope, attrs) when is_list(attrs) do
    now = DateTime.utc_now(:second)

    entries = Enum.map(attrs, &Payloads.playlist_entry(&1, user_id: scope.user.id, now: now))

    Repo.insert_all(Playlist, entries,
      conflict_target: [:user_id, :client_id],
      on_conflict: {:replace, [:name, :kind, :updated_at]}
    )
  end

  def replace_playlist_tracks(%Scope{} = scope, attrs) when is_list(attrs) do
    now = DateTime.utc_now(:second)

    playlist_id_by_client_id = client_id_to_playlist_id(attrs, scope)

    track_id_by_client_id =
      attrs
      |> Enum.flat_map(&Map.get(&1, "tracks", []))
      |> client_id_to_track_id(scope)

    Enum.each(attrs, fn attr ->
      playlist_client_id = Parsers.parse_uuid!(attr, "playlist_client_id")
      playlist_id = Map.fetch!(playlist_id_by_client_id, playlist_client_id)

      entries =
        attr
        |> Map.get("tracks", [])
        |> Enum.map(fn track_attr ->
          track_attr
          |> put_mapped_id!("track_client_id", "track_id", track_id_by_client_id)
          |> Payloads.playlist_track_entry(
            user_id: scope.user.id,
            playlist_id: playlist_id,
            now: now
          )
        end)

      Repo.transaction(fn ->
        from(pt in PlaylistTrack,
          where: pt.user_id == ^scope.user.id and pt.playlist_id == ^playlist_id
        )
        |> Repo.delete_all()

        if entries != [] do
          Repo.insert_all(PlaylistTrack, entries)
        end
      end)
    end)
  end

  def upsert_playback_events(%Scope{} = scope, attrs) when is_list(attrs) do
    now = DateTime.utc_now(:second)

    track_id_by_client_id = client_id_to_track_id(attrs, scope)

    entries =
      Enum.map(attrs, fn attr ->
        attr
        |> put_mapped_id!("track_client_id", "track_id", track_id_by_client_id)
        |> Payloads.playback_event_entry(user_id: scope.user.id, now: now)
      end)

    Repo.insert_all(PlaybackEvent, entries,
      conflict_target: [:user_id, :client_id],
      on_conflict:
        {:replace,
         [
           :event_type,
           :played_at,
           :position_seconds,
           :duration_seconds,
           :context_type,
           :context_client_id,
           :track_id,
           :updated_at
         ]}
    )
  end

  defp client_id_to_artist_id(attrs, scope) do
    attrs
    |> Parsers.distinct_uuids("artist_client_id")
    |> Music.fetch_artist_ids(scope)
  end

  defp client_id_to_album_id(attrs, scope) do
    attrs
    |> Parsers.distinct_uuids("album_client_id")
    |> Music.fetch_album_ids(scope)
  end

  defp client_id_to_playlist_id(attrs, scope) do
    attrs
    |> Parsers.distinct_uuids("playlist_client_id")
    |> Playlists.fetch_playlists_ids(scope)
  end

  defp client_id_to_track_id(attrs, scope) do
    attrs
    |> Parsers.distinct_uuids("track_client_id")
    |> Music.fetch_tracks_ids(scope)
  end

  defp put_mapped_id(attr, client_id_key, id_key, id_by_client_id) do
    case Parsers.parse_uuid(attr, client_id_key) do
      nil ->
        attr

      client_id ->
        case Map.fetch(id_by_client_id, client_id) do
          {:ok, id} -> Map.put(attr, id_key, id)
          :error -> attr
        end
    end
  end

  defp put_mapped_id!(attr, client_id_key, id_key, id_by_client_id) do
    client_id = Parsers.parse_uuid!(attr, client_id_key)
    id = Map.fetch!(id_by_client_id, client_id)

    Map.put(attr, id_key, id)
  end
end
