defmodule CrateStation.PlaylistsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CrateStation.Playlists` context.
  """

  @doc """
  Generate a playlist.
  """
  def playlist_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        client_id: Ecto.UUID.generate(),
        kind: :regular,
        name: "some name"
      })

    {:ok, playlist} = CrateStation.Playlists.create_playlist(scope, attrs)
    playlist
  end

  @doc """
  Generate a playlist_track.
  """
  def playlist_track_fixture(scope, attrs \\ %{}) do
    playlist = playlist_fixture(scope)
    track = CrateStation.MusicFixtures.track_fixture(scope)

    attrs =
      Enum.into(attrs, %{
        playlist_id: playlist.id,
        position: 42,
        track_id: track.id
      })

    {:ok, playlist_track} = CrateStation.Playlists.create_playlist_track(scope, attrs)
    playlist_track
  end
end
