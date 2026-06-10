defmodule CrateStation.Ingest do
  import Ecto.Query, warn: false
  alias CrateStation.Repo

  alias CrateStation.Accounts.Scope
  alias CrateStation.Music.{Album, Track, Artist}

  def upsert_artists(%Scope{} = scope, attrs) when is_list(attrs) do
    now = DateTime.utc_now(:second)

    entries =
      Enum.map(attrs, fn attr ->
        %{
          client_id: attr["client_id"],
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
          client_id: attr["client_id"],
          title: attr["title"],
          year: Map.get(attr, "year"),
          genre: Map.get(attr, "genre"),
          artist_id: Map.get(artist_id_by_client_id, attr["artist_client_id"]),
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
          client_id: attr["client_id"],
          title: attr["title"],
          duration: attr["duration"],
          track_number: attr["track_number"],
          disc_number: attr["disc_number"],
          year: attr["year"],
          genre: attr["genre"],
          bpm: attr["bpm"],
          song_key: attr["song_key"],
          play_count: attr["play_count"],
          rating: attr["rating"],
          is_favorite: attr["is_favorite"],
          last_played_at: attr["last_played_at"],
          imported_at: attr["imported_at"],
          album_id: Map.get(album_id_by_client_id, attr["album_client_id"]),
          artist_id: Map.get(artist_id_by_client_id, attr["artist_client_id"]),
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

  defp client_id_to_artist_id(attrs, scope) do
    attrs
    |> distinct_values("artist_client_id")
    |> fetch_artist_ids(scope)
  end

  defp client_id_to_album_id(attrs, scope) do
    attrs
    |> distinct_values("album_client_id")
    |> fetch_album_ids(scope)
  end

  defp fetch_artist_ids(albums_client_ids, scope) do
    from(a in Artist,
      where: a.user_id == ^scope.user.id and a.client_id in ^albums_client_ids,
      select: {a.client_id, a.id}
    )
    |> Repo.all()
    |> Map.new()
  end

  defp fetch_album_ids(artist_client_ids, scope) do
    from(a in Album,
      where: a.user_id == ^scope.user.id and a.client_id in ^artist_client_ids,
      select: {a.client_id, a.id}
    )
    |> Repo.all()
    |> Map.new()
  end

  defp distinct_values(attrs, key) do
    attrs
    |> Enum.map(& &1[key])
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end
end
