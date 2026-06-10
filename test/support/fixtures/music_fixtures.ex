defmodule CrateStation.MusicFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CrateStation.Music` context.
  """

  @doc """
  Generate a artist.
  """
  def artist_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        client_id: Ecto.UUID.generate(),
        name: "some name",
        slug: "some slug"
      })

    {:ok, artist} = CrateStation.Music.create_artist(scope, attrs)
    artist
  end

  @doc """
  Generate a album.
  """
  def album_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        client_id: Ecto.UUID.generate(),
        genre: "some genre",
        title: "some title",
        year: 42
      })

    {:ok, album} = CrateStation.Music.create_album(scope, attrs)
    album
  end

  @doc """
  Generate a track.
  """
  def track_fixture(scope, attrs \\ %{}) do
    artist = artist_fixture(scope)

    attrs =
      Enum.into(attrs, %{
        bpm: 120.5,
        artist_id: artist.id,
        client_id: Ecto.UUID.generate(),
        disc_number: 42,
        duration: 42,
        genre: "electro",
        imported_at: ~U[2026-06-09 01:28:00Z],
        is_favorite: true,
        last_played_at: ~U[2026-06-09 01:28:00Z],
        play_count: 42,
        rating: 42,
        song_key: "some song_key",
        title: "some title",
        track_number: 42,
        year: 42
      })

    {:ok, track} = CrateStation.Music.create_track(scope, attrs)
    track
  end
end
