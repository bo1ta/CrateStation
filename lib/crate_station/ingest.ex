defmodule CrateStation.Ingest do
  import Ecto.Query, warn: false
  import CrateStation.Helpers.ClientHelpers

  alias CrateStation.Playlists
  alias CrateStation.Music
  alias CrateStation.Repo

  alias CrateStation.Accounts.Scope
  alias CrateStation.Music.{Album, Track, Artist}
  alias CrateStation.Playlists.{Playlist, PlaylistTrack}

  def upsert_artists(%Scope{} = scope, attrs) when is_list(attrs) do
    now = DateTime.utc_now(:second)

    entries =
      Enum.map(attrs, fn attr ->
        %{
          client_id: client_id(attr, "client_id"),
          name: attr["name"],
          slug: attr["slug"],
          user_id: scope.user.id,
          inserted_at: now,
          updated_at: now
        }
      end)

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
        %{
          client_id: client_id(attr, "client_id"),
          title: attr["title"],
          year: Map.get(attr, "year"),
          genre: Map.get(attr, "genre"),
          artist_id: Map.get(artist_id_by_client_id, client_id(attr, "artist_client_id")),
          user_id: scope.user.id,
          inserted_at: now,
          updated_at: now
        }
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
        %{
          client_id: client_id(attr, "client_id"),
          title: attr["title"],
          duration: attr["duration"],
          track_number: attr["track_number"],
          disc_number: attr["disc_number"],
          year: attr["year"],
          genre: attr["genre"],
          bpm: :erlang.float(attr["bpm"]),
          song_key: attr["song_key"],
          play_count: attr["play_count"],
          rating: attr["rating"],
          is_favorite: attr["is_favorite"],
          last_played_at: parse_utc_datetime(attr["last_played_at"]),
          imported_at: parse_utc_datetime(attr["imported_at"]),
          album_id: Map.get(album_id_by_client_id, client_id(attr, "album_client_id")),
          artist_id: Map.get(artist_id_by_client_id, client_id(attr, "artist_client_id")),
          user_id: scope.user.id,
          inserted_at: now,
          updated_at: now
        }
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

    entries =
      Enum.map(attrs, fn attr ->
        %{
          client_id: client_id(attr, "client_id"),
          name: attr["name"],
          kind: String.to_atom(attr["kind"]),
          user_id: scope.user.id,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(Playlist, entries,
      conflict_target: [:user_id, :client_id],
      on_conflict: {:replace, [:name, :kind, :updated_at]}
    )
  end

  def replace_playlist_tracks(%Scope{} = scope, attrs) when is_list(attrs) do
    now = DateTime.utc_now(:second)

    playlist_id_by_client_id = client_id_to_playlist_id(attrs, scope)
    track_id_by_client_id = client_id_to_track_id(attrs, scope)

    Enum.each(attrs, fn attr ->
      playlist_id = Map.fetch!(playlist_id_by_client_id, client_id(attr, "playlist_client_id"))

      entries =
        attr
        |> Map.get("tracks", [])
        |> Enum.map(fn track_attr ->
          %{
            user_id: scope.user.id,
            playlist_id: playlist_id,
            track_id: Map.fetch!(track_id_by_client_id, client_id(track_attr, "track_client_id")),
            position: track_attr["position"],
            inserted_at: now,
            updated_at: now
          }
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

  defp client_id_to_artist_id(attrs, scope) do
    attrs
    |> distinct_values("artist_client_id")
    |> Music.fetch_artist_ids(scope)
  end

  defp client_id_to_album_id(attrs, scope) do
    attrs
    |> distinct_values("album_client_id")
    |> Music.fetch_album_ids(scope)
  end

  defp client_id_to_playlist_id(attrs, scope) do
    attrs
    |> distinct_values("playlist_client_id")
    |> Playlists.fetch_playlists_ids(scope)
  end

  defp client_id_to_track_id(attrs, scope) do
    attrs
    |> Enum.flat_map(&Map.get(&1, "tracks", []))
    |> distinct_values("track_client_id")
    |> Music.fetch_tracks_ids(scope)
  end
end
