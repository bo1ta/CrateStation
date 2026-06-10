defmodule CrateStation.MusicTest do
  use CrateStation.DataCase

  alias CrateStation.Music

  describe "artists" do
    alias CrateStation.Music.Artist

    import CrateStation.AccountsFixtures, only: [user_scope_fixture: 0]
    import CrateStation.MusicFixtures

    @invalid_attrs %{name: nil, slug: nil, client_id: nil}

    test "list_artists/1 returns all scoped artists" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      artist = artist_fixture(scope)
      other_artist = artist_fixture(other_scope)
      assert Music.list_artists(scope) == [artist]
      assert Music.list_artists(other_scope) == [other_artist]
    end

    test "get_artist!/2 returns the artist with given id" do
      scope = user_scope_fixture()
      artist = artist_fixture(scope)
      other_scope = user_scope_fixture()
      assert Music.get_artist!(scope, artist.id) == artist
      assert_raise Ecto.NoResultsError, fn -> Music.get_artist!(other_scope, artist.id) end
    end

    test "create_artist/2 with valid data creates a artist" do
      valid_attrs = %{
        name: "some name",
        slug: "some slug",
        client_id: "7488a646-e31f-11e4-aace-600308960662"
      }

      scope = user_scope_fixture()

      assert {:ok, %Artist{} = artist} = Music.create_artist(scope, valid_attrs)
      assert artist.name == "some name"
      assert artist.slug == "some slug"
      assert artist.client_id == "7488a646-e31f-11e4-aace-600308960662"
      assert artist.user_id == scope.user.id
    end

    test "create_artist/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Music.create_artist(scope, @invalid_attrs)
    end

    test "update_artist/3 with valid data updates the artist" do
      scope = user_scope_fixture()
      artist = artist_fixture(scope)

      update_attrs = %{
        name: "some updated name",
        slug: "some updated slug",
        client_id: "7488a646-e31f-11e4-aace-600308960668"
      }

      assert {:ok, %Artist{} = artist} = Music.update_artist(scope, artist, update_attrs)
      assert artist.name == "some updated name"
      assert artist.slug == "some updated slug"
      assert artist.client_id == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_artist/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      artist = artist_fixture(scope)

      assert_raise MatchError, fn ->
        Music.update_artist(other_scope, artist, %{})
      end
    end

    test "update_artist/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      artist = artist_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Music.update_artist(scope, artist, @invalid_attrs)
      assert artist == Music.get_artist!(scope, artist.id)
    end

    test "delete_artist/2 deletes the artist" do
      scope = user_scope_fixture()
      artist = artist_fixture(scope)
      assert {:ok, %Artist{}} = Music.delete_artist(scope, artist)
      assert_raise Ecto.NoResultsError, fn -> Music.get_artist!(scope, artist.id) end
    end

    test "delete_artist/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      artist = artist_fixture(scope)
      assert_raise MatchError, fn -> Music.delete_artist(other_scope, artist) end
    end

    test "change_artist/2 returns a artist changeset" do
      scope = user_scope_fixture()
      artist = artist_fixture(scope)
      assert %Ecto.Changeset{} = Music.change_artist(scope, artist)
    end
  end

  describe "albums" do
    alias CrateStation.Music.Album

    import CrateStation.AccountsFixtures, only: [user_scope_fixture: 0]
    import CrateStation.MusicFixtures

    @invalid_attrs %{title: nil, year: nil, genre: nil, duration: nil, client_id: nil}

    test "list_albums/1 returns all scoped albums" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      album = album_fixture(scope)
      other_album = album_fixture(other_scope)
      assert Music.list_albums(scope) == [album]
      assert Music.list_albums(other_scope) == [other_album]
    end

    test "get_album!/2 returns the album with given id" do
      scope = user_scope_fixture()
      album = album_fixture(scope)
      other_scope = user_scope_fixture()
      assert Music.get_album!(scope, album.id) == album
      assert_raise Ecto.NoResultsError, fn -> Music.get_album!(other_scope, album.id) end
    end

    test "create_album/2 with valid data creates a album" do
      valid_attrs = %{
        title: "some title",
        year: 42,
        genre: "some genre",
        duration: 42,
        client_id: "7488a646-e31f-11e4-aace-600308960663"
      }

      scope = user_scope_fixture()

      assert {:ok, %Album{} = album} = Music.create_album(scope, valid_attrs)
      assert album.title == "some title"
      assert album.year == 42
      assert album.genre == "some genre"
      assert album.duration == 42
      assert album.client_id == "7488a646-e31f-11e4-aace-600308960663"
      assert album.user_id == scope.user.id
    end

    test "create_album/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Music.create_album(scope, @invalid_attrs)
    end

    test "update_album/3 with valid data updates the album" do
      scope = user_scope_fixture()
      album = album_fixture(scope)

      update_attrs = %{
        title: "some updated title",
        year: 43,
        genre: "some updated genre",
        duration: 43
      }

      assert {:ok, %Album{} = album} = Music.update_album(scope, album, update_attrs)
      assert album.title == "some updated title"
      assert album.year == 43
      assert album.genre == "some updated genre"
      assert album.duration == 43
    end

    test "update_album/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      album = album_fixture(scope)

      assert_raise MatchError, fn ->
        Music.update_album(other_scope, album, %{})
      end
    end

    test "update_album/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      album = album_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Music.update_album(scope, album, @invalid_attrs)
      assert album == Music.get_album!(scope, album.id)
    end

    test "delete_album/2 deletes the album" do
      scope = user_scope_fixture()
      album = album_fixture(scope)
      assert {:ok, %Album{}} = Music.delete_album(scope, album)
      assert_raise Ecto.NoResultsError, fn -> Music.get_album!(scope, album.id) end
    end

    test "delete_album/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      album = album_fixture(scope)
      assert_raise MatchError, fn -> Music.delete_album(other_scope, album) end
    end

    test "change_album/2 returns a album changeset" do
      scope = user_scope_fixture()
      album = album_fixture(scope)
      assert %Ecto.Changeset{} = Music.change_album(scope, album)
    end
  end

  describe "tracks" do
    alias CrateStation.Music.Track

    import CrateStation.AccountsFixtures, only: [user_scope_fixture: 0]
    import CrateStation.MusicFixtures

    @invalid_attrs %{
      title: nil,
      year: nil,
      duration: nil,
      track_number: nil,
      disc_number: nil,
      genre: nil,
      bpm: nil,
      song_key: nil,
      play_count: nil,
      rating: nil,
      is_favorite: nil,
      last_played_at: nil,
      imported_at: nil,
      artist_id: nil
    }

    test "list_tracks/1 returns all scoped tracks" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      track = track_fixture(scope)
      other_track = track_fixture(other_scope)
      assert Music.list_tracks(scope) == [track]
      assert Music.list_tracks(other_scope) == [other_track]
    end

    test "get_track!/2 returns the track with given id" do
      scope = user_scope_fixture()
      track = track_fixture(scope)
      other_scope = user_scope_fixture()
      assert Music.get_track!(scope, track.id) == track
      assert_raise Ecto.NoResultsError, fn -> Music.get_track!(other_scope, track.id) end
    end

    test "create_track/2 with valid data creates a track" do
      scope = user_scope_fixture()
      artist = artist_fixture(scope)

      valid_attrs = %{
        title: "some title",
        year: 42,
        duration: 42,
        track_number: 42,
        disc_number: 42,
        genre: 42,
        bpm: 120.5,
        song_key: "some song_key",
        play_count: 42,
        rating: 42,
        is_favorite: true,
        last_played_at: ~U[2026-06-09 01:28:00Z],
        imported_at: ~U[2026-06-09 01:28:00Z],
        artist_id: artist.id
      }

      assert {:ok, %Track{} = track} = Music.create_track(scope, valid_attrs)
      assert track.title == "some title"
      assert track.year == 42
      assert track.duration == 42
      assert track.track_number == 42
      assert track.disc_number == 42
      assert track.genre == 42
      assert track.bpm == 120.5
      assert track.song_key == "some song_key"
      assert track.play_count == 42
      assert track.rating == 42
      assert track.is_favorite == true
      assert track.last_played_at == ~U[2026-06-09 01:28:00Z]
      assert track.imported_at == ~U[2026-06-09 01:28:00Z]
      assert track.artist_id == artist.id
      assert track.user_id == scope.user.id
    end

    test "create_track/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Music.create_track(scope, @invalid_attrs)
    end

    test "update_track/3 with valid data updates the track" do
      scope = user_scope_fixture()
      track = track_fixture(scope)

      update_attrs = %{
        title: "some updated title",
        year: 43,
        duration: 43,
        track_number: 43,
        disc_number: 43,
        genre: 43,
        bpm: 456.7,
        song_key: "some updated song_key",
        play_count: 43,
        rating: 43,
        is_favorite: false,
        last_played_at: ~U[2026-06-10 01:28:00Z],
        imported_at: ~U[2026-06-10 01:28:00Z]
      }

      assert {:ok, %Track{} = track} = Music.update_track(scope, track, update_attrs)
      assert track.title == "some updated title"
      assert track.year == 43
      assert track.duration == 43
      assert track.track_number == 43
      assert track.disc_number == 43
      assert track.genre == 43
      assert track.bpm == 456.7
      assert track.song_key == "some updated song_key"
      assert track.play_count == 43
      assert track.rating == 43
      assert track.is_favorite == false
      assert track.last_played_at == ~U[2026-06-10 01:28:00Z]
      assert track.imported_at == ~U[2026-06-10 01:28:00Z]
    end

    test "update_track/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      track = track_fixture(scope)

      assert_raise MatchError, fn ->
        Music.update_track(other_scope, track, %{})
      end
    end

    test "update_track/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      track = track_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Music.update_track(scope, track, @invalid_attrs)
      assert track == Music.get_track!(scope, track.id)
    end

    test "delete_track/2 deletes the track" do
      scope = user_scope_fixture()
      track = track_fixture(scope)
      assert {:ok, %Track{}} = Music.delete_track(scope, track)
      assert_raise Ecto.NoResultsError, fn -> Music.get_track!(scope, track.id) end
    end

    test "delete_track/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      track = track_fixture(scope)
      assert_raise MatchError, fn -> Music.delete_track(other_scope, track) end
    end

    test "change_track/2 returns a track changeset" do
      scope = user_scope_fixture()
      track = track_fixture(scope)
      assert %Ecto.Changeset{} = Music.change_track(scope, track)
    end
  end
end
