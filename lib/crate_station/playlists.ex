defmodule CrateStation.Playlists do
  @moduledoc """
  The Playlists context.
  """

  import Ecto.Query, warn: false
  alias CrateStation.Repo

  alias CrateStation.Playlists.Playlist
  alias CrateStation.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any playlist changes.

  The broadcasted messages match the pattern:

    * {:created, %Playlist{}}
    * {:updated, %Playlist{}}
    * {:deleted, %Playlist{}}

  """
  def subscribe_playlists(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(CrateStation.PubSub, "user:#{key}:playlists")
  end

  defp broadcast_playlist(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(CrateStation.PubSub, "user:#{key}:playlists", message)
  end

  @doc """
  Returns the list of playlists.

  ## Examples

      iex> list_playlists(scope)
      [%Playlist{}, ...]

  """
  def list_playlists(%Scope{} = scope) do
    Repo.all_by(Playlist, user_id: scope.user.id)
  end

  @doc """
  Gets a single playlist.

  Raises `Ecto.NoResultsError` if the Playlist does not exist.

  ## Examples

      iex> get_playlist!(scope, 123)
      %Playlist{}

      iex> get_playlist!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_playlist!(%Scope{} = scope, id) do
    Repo.get_by!(Playlist, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a playlist.

  ## Examples

      iex> create_playlist(scope, %{field: value})
      {:ok, %Playlist{}}

      iex> create_playlist(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_playlist(%Scope{} = scope, attrs) do
    with {:ok, playlist = %Playlist{}} <-
           %Playlist{}
           |> Playlist.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_playlist(scope, {:created, playlist})
      {:ok, playlist}
    end
  end

  @doc """
  Updates a playlist.

  ## Examples

      iex> update_playlist(scope, playlist, %{field: new_value})
      {:ok, %Playlist{}}

      iex> update_playlist(scope, playlist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_playlist(%Scope{} = scope, %Playlist{} = playlist, attrs) do
    true = playlist.user_id == scope.user.id

    with {:ok, playlist = %Playlist{}} <-
           playlist
           |> Playlist.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_playlist(scope, {:updated, playlist})
      {:ok, playlist}
    end
  end

  @doc """
  Deletes a playlist.

  ## Examples

      iex> delete_playlist(scope, playlist)
      {:ok, %Playlist{}}

      iex> delete_playlist(scope, playlist)
      {:error, %Ecto.Changeset{}}

  """
  def delete_playlist(%Scope{} = scope, %Playlist{} = playlist) do
    true = playlist.user_id == scope.user.id

    with {:ok, playlist = %Playlist{}} <-
           Repo.delete(playlist) do
      broadcast_playlist(scope, {:deleted, playlist})
      {:ok, playlist}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking playlist changes.

  ## Examples

      iex> change_playlist(scope, playlist)
      %Ecto.Changeset{data: %Playlist{}}

  """
  def change_playlist(%Scope{} = scope, %Playlist{} = playlist, attrs \\ %{}) do
    true = playlist.user_id == scope.user.id

    Playlist.changeset(playlist, attrs, scope)
  end

  alias CrateStation.Playlists.PlaylistTrack
  alias CrateStation.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any playlist_track changes.

  The broadcasted messages match the pattern:

    * {:created, %PlaylistTrack{}}
    * {:updated, %PlaylistTrack{}}
    * {:deleted, %PlaylistTrack{}}

  """
  def subscribe_playlist_tracks(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(CrateStation.PubSub, "user:#{key}:playlist_tracks")
  end

  defp broadcast_playlist_track(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(CrateStation.PubSub, "user:#{key}:playlist_tracks", message)
  end

  @doc """
  Returns the list of playlist_tracks.

  ## Examples

      iex> list_playlist_tracks(scope)
      [%PlaylistTrack{}, ...]

  """
  def list_playlist_tracks(%Scope{} = scope) do
    Repo.all_by(PlaylistTrack, user_id: scope.user.id)
  end

  @doc """
  Gets a single playlist_track.

  Raises `Ecto.NoResultsError` if the Playlist track does not exist.

  ## Examples

      iex> get_playlist_track!(scope, 123)
      %PlaylistTrack{}

      iex> get_playlist_track!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_playlist_track!(%Scope{} = scope, id) do
    Repo.get_by!(PlaylistTrack, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a playlist_track.

  ## Examples

      iex> create_playlist_track(scope, %{field: value})
      {:ok, %PlaylistTrack{}}

      iex> create_playlist_track(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_playlist_track(%Scope{} = scope, attrs) do
    with {:ok, playlist_track = %PlaylistTrack{}} <-
           %PlaylistTrack{}
           |> PlaylistTrack.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_playlist_track(scope, {:created, playlist_track})
      {:ok, playlist_track}
    end
  end

  @doc """
  Updates a playlist_track.

  ## Examples

      iex> update_playlist_track(scope, playlist_track, %{field: new_value})
      {:ok, %PlaylistTrack{}}

      iex> update_playlist_track(scope, playlist_track, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_playlist_track(%Scope{} = scope, %PlaylistTrack{} = playlist_track, attrs) do
    true = playlist_track.user_id == scope.user.id

    with {:ok, playlist_track = %PlaylistTrack{}} <-
           playlist_track
           |> PlaylistTrack.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_playlist_track(scope, {:updated, playlist_track})
      {:ok, playlist_track}
    end
  end

  @doc """
  Deletes a playlist_track.

  ## Examples

      iex> delete_playlist_track(scope, playlist_track)
      {:ok, %PlaylistTrack{}}

      iex> delete_playlist_track(scope, playlist_track)
      {:error, %Ecto.Changeset{}}

  """
  def delete_playlist_track(%Scope{} = scope, %PlaylistTrack{} = playlist_track) do
    true = playlist_track.user_id == scope.user.id

    with {:ok, playlist_track = %PlaylistTrack{}} <-
           Repo.delete(playlist_track) do
      broadcast_playlist_track(scope, {:deleted, playlist_track})
      {:ok, playlist_track}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking playlist_track changes.

  ## Examples

      iex> change_playlist_track(scope, playlist_track)
      %Ecto.Changeset{data: %PlaylistTrack{}}

  """
  def change_playlist_track(%Scope{} = scope, %PlaylistTrack{} = playlist_track, attrs \\ %{}) do
    true = playlist_track.user_id == scope.user.id

    PlaylistTrack.changeset(playlist_track, attrs, scope)
  end
end
