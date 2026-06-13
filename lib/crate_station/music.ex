defmodule CrateStation.Music do
  @moduledoc """
  The Music context.
  """

  import Ecto.Query, warn: false
  alias CrateStation.Repo

  alias CrateStation.Music.Artist
  alias CrateStation.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any artist changes.

  The broadcasted messages match the pattern:

    * {:created, %Artist{}}
    * {:updated, %Artist{}}
    * {:deleted, %Artist{}}

  """
  def subscribe_artists(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(CrateStation.PubSub, "user:#{key}:artists")
  end

  defp broadcast_artist(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(CrateStation.PubSub, "user:#{key}:artists", message)
  end

  @doc """
  Returns the list of artists.

  ## Examples

      iex> list_artists(scope)
      [%Artist{}, ...]

  """
  def list_artists(%Scope{} = scope) do
    Repo.all_by(Artist, user_id: scope.user.id)
  end

  @doc """
  Gets a single artist.

  Raises `Ecto.NoResultsError` if the Artist does not exist.

  ## Examples

      iex> get_artist!(scope, 123)
      %Artist{}

      iex> get_artist!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_artist!(%Scope{} = scope, id) do
    Repo.get_by!(Artist, id: id, user_id: scope.user.id)
  end

  def artist_by_client_id(%Scope{} = scope, client_id) do
    Repo.get_by(Artist, client_id: client_id, user_id: scope.user.id)
  end

  @doc """
  Creates a artist.

  ## Examples

      iex> create_artist(scope, %{field: value})
      {:ok, %Artist{}}

      iex> create_artist(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_artist(%Scope{} = scope, attrs) do
    with {:ok, artist = %Artist{}} <-
           %Artist{}
           |> Artist.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_artist(scope, {:created, artist})
      {:ok, artist}
    end
  end

  @doc """
  Updates a artist.

  ## Examples

      iex> update_artist(scope, artist, %{field: new_value})
      {:ok, %Artist{}}

      iex> update_artist(scope, artist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_artist(%Scope{} = scope, %Artist{} = artist, attrs) do
    true = artist.user_id == scope.user.id

    with {:ok, artist = %Artist{}} <-
           artist
           |> Artist.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_artist(scope, {:updated, artist})
      {:ok, artist}
    end
  end

  @doc """
  Deletes a artist.

  ## Examples

      iex> delete_artist(scope, artist)
      {:ok, %Artist{}}

      iex> delete_artist(scope, artist)
      {:error, %Ecto.Changeset{}}

  """
  def delete_artist(%Scope{} = scope, %Artist{} = artist) do
    true = artist.user_id == scope.user.id

    with {:ok, artist = %Artist{}} <-
           Repo.delete(artist) do
      broadcast_artist(scope, {:deleted, artist})
      {:ok, artist}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking artist changes.

  ## Examples

      iex> change_artist(scope, artist)
      %Ecto.Changeset{data: %Artist{}}

  """
  def change_artist(%Scope{} = scope, %Artist{} = artist, attrs \\ %{}) do
    true = artist.user_id == scope.user.id

    Artist.changeset(artist, attrs, scope)
  end

  alias CrateStation.Music.Album
  alias CrateStation.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any album changes.

  The broadcasted messages match the pattern:

    * {:created, %Album{}}
    * {:updated, %Album{}}
    * {:deleted, %Album{}}

  """
  def subscribe_albums(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(CrateStation.PubSub, "user:#{key}:albums")
  end

  defp broadcast_album(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(CrateStation.PubSub, "user:#{key}:albums", message)
  end

  @doc """
  Returns the list of albums.

  ## Examples

      iex> list_albums(scope)
      [%Album{}, ...]

  """
  def list_albums(%Scope{} = scope) do
    Repo.all_by(Album, user_id: scope.user.id)
  end

  @doc """
  Gets a single album.

  Raises `Ecto.NoResultsError` if the Album does not exist.

  ## Examples

      iex> get_album!(scope, 123)
      %Album{}

      iex> get_album!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_album!(%Scope{} = scope, id) do
    Repo.get_by!(Album, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a album.

  ## Examples

      iex> create_album(scope, %{field: value})
      {:ok, %Album{}}

      iex> create_album(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_album(%Scope{} = scope, attrs) do
    with {:ok, album = %Album{}} <-
           %Album{}
           |> Album.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_album(scope, {:created, album})
      {:ok, album}
    end
  end

  @doc """
  Updates a album.

  ## Examples

      iex> update_album(scope, album, %{field: new_value})
      {:ok, %Album{}}

      iex> update_album(scope, album, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_album(%Scope{} = scope, %Album{} = album, attrs) do
    true = album.user_id == scope.user.id

    with {:ok, album = %Album{}} <-
           album
           |> Album.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_album(scope, {:updated, album})
      {:ok, album}
    end
  end

  @doc """
  Deletes a album.

  ## Examples

      iex> delete_album(scope, album)
      {:ok, %Album{}}

      iex> delete_album(scope, album)
      {:error, %Ecto.Changeset{}}

  """
  def delete_album(%Scope{} = scope, %Album{} = album) do
    true = album.user_id == scope.user.id

    with {:ok, album = %Album{}} <-
           Repo.delete(album) do
      broadcast_album(scope, {:deleted, album})
      {:ok, album}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking album changes.

  ## Examples

      iex> change_album(scope, album)
      %Ecto.Changeset{data: %Album{}}

  """
  def change_album(%Scope{} = scope, %Album{} = album, attrs \\ %{}) do
    true = album.user_id == scope.user.id

    Album.changeset(album, attrs, scope)
  end

  alias CrateStation.Music.Track
  alias CrateStation.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any track changes.

  The broadcasted messages match the pattern:

    * {:created, %Track{}}
    * {:updated, %Track{}}
    * {:deleted, %Track{}}

  """
  def subscribe_tracks(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(CrateStation.PubSub, "user:#{key}:tracks")
  end

  defp broadcast_track(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(CrateStation.PubSub, "user:#{key}:tracks", message)
  end

  @doc """
  Returns the list of tracks.

  ## Examples

      iex> list_tracks(scope)
      [%Track{}, ...]

  """
  def list_tracks(%Scope{} = scope) do
    Repo.all_by(Track, user_id: scope.user.id)
  end

  @doc """
  Gets a single track.

  Raises `Ecto.NoResultsError` if the Track does not exist.

  ## Examples

      iex> get_track!(scope, 123)
      %Track{}

      iex> get_track!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_track!(%Scope{} = scope, id) do
    Repo.get_by!(Track, id: id, user_id: scope.user.id)
  end

  def track_by_client_id(%Scope{} = scope, client_id) when is_binary(client_id) do
    Repo.get_by(Track, client_id: client_id, user_id: scope.user.id)
  end

  def track_by_client_id(_scope, _), do: nil

  @doc """
  Creates a track.

  ## Examples

      iex> create_track(scope, %{field: value})
      {:ok, %Track{}}

      iex> create_track(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_track(%Scope{} = scope, attrs) do
    with {:ok, track = %Track{}} <-
           %Track{}
           |> Track.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_track(scope, {:created, track})
      {:ok, track}
    end
  end

  @doc """
  Updates a track.

  ## Examples

      iex> update_track(scope, track, %{field: new_value})
      {:ok, %Track{}}

      iex> update_track(scope, track, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_track(%Scope{} = scope, %Track{} = track, attrs) do
    true = track.user_id == scope.user.id

    with {:ok, track = %Track{}} <-
           track
           |> Track.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_track(scope, {:updated, track})
      {:ok, track}
    end
  end

  @doc """
  Deletes a track.

  ## Examples

      iex> delete_track(scope, track)
      {:ok, %Track{}}

      iex> delete_track(scope, track)
      {:error, %Ecto.Changeset{}}

  """
  def delete_track(%Scope{} = scope, %Track{} = track) do
    true = track.user_id == scope.user.id

    with {:ok, track = %Track{}} <-
           Repo.delete(track) do
      broadcast_track(scope, {:deleted, track})
      {:ok, track}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking track changes.

  ## Examples

      iex> change_track(scope, track)
      %Ecto.Changeset{data: %Track{}}

  """
  def change_track(%Scope{} = scope, %Track{} = track, attrs \\ %{}) do
    true = track.user_id == scope.user.id

    Track.changeset(track, attrs, scope)
  end

  def fetch_tracks_ids(tracks_client_ids, scope) do
    from(t in Track,
      where: t.user_id == ^scope.user.id and t.client_id in ^tracks_client_ids,
      select: {t.client_id, t.id}
    )
    |> Repo.all()
    |> Map.new()
  end

  def fetch_artist_ids(albums_client_ids, scope) do
    from(a in Artist,
      where: a.user_id == ^scope.user.id and a.client_id in ^albums_client_ids,
      select: {a.client_id, a.id}
    )
    |> Repo.all()
    |> Map.new()
  end

  def fetch_album_ids(artist_client_ids, scope) do
    from(a in Album,
      where: a.user_id == ^scope.user.id and a.client_id in ^artist_client_ids,
      select: {a.client_id, a.id}
    )
    |> Repo.all()
    |> Map.new()
  end

  def album_by_client_id(%Scope{} = scope, client_id) do
    Repo.get_by(Album, user_id: scope.user.id, client_id: client_id)
  end
end
