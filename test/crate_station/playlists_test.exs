defmodule CrateStation.PlaylistsTest do
  use CrateStation.DataCase

  alias CrateStation.Playlists

  describe "playlists" do
    alias CrateStation.Playlists.Playlist

    import CrateStation.AccountsFixtures, only: [user_scope_fixture: 0]
    import CrateStation.PlaylistsFixtures

    @invalid_attrs %{name: nil, kind: nil, client_id: nil}

    test "list_playlists/1 returns all scoped playlists" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      playlist = playlist_fixture(scope)
      other_playlist = playlist_fixture(other_scope)
      assert Playlists.list_playlists(scope) == [playlist]
      assert Playlists.list_playlists(other_scope) == [other_playlist]
    end

    test "get_playlist!/2 returns the playlist with given id" do
      scope = user_scope_fixture()
      playlist = playlist_fixture(scope)
      other_scope = user_scope_fixture()
      assert Playlists.get_playlist!(scope, playlist.id) == playlist

      assert_raise Ecto.NoResultsError, fn ->
        Playlists.get_playlist!(other_scope, playlist.id)
      end
    end

    test "create_playlist/2 with valid data creates a playlist" do
      valid_attrs = %{
        name: "some name",
        kind: :regular,
        client_id: "7488a646-e31f-11e4-aace-600308960662"
      }

      scope = user_scope_fixture()

      assert {:ok, %Playlist{} = playlist} = Playlists.create_playlist(scope, valid_attrs)
      assert playlist.name == "some name"
      assert playlist.kind == :regular
      assert playlist.client_id == "7488a646-e31f-11e4-aace-600308960662"
      assert playlist.user_id == scope.user.id
    end

    test "create_playlist/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Playlists.create_playlist(scope, @invalid_attrs)
    end

    test "update_playlist/3 with valid data updates the playlist" do
      scope = user_scope_fixture()
      playlist = playlist_fixture(scope)

      update_attrs = %{
        name: "some updated name",
        kind: :smart,
        client_id: "7488a646-e31f-11e4-aace-600308960668"
      }

      assert {:ok, %Playlist{} = playlist} =
               Playlists.update_playlist(scope, playlist, update_attrs)

      assert playlist.name == "some updated name"
      assert playlist.kind == :smart
      assert playlist.client_id == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_playlist/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      playlist = playlist_fixture(scope)

      assert_raise MatchError, fn ->
        Playlists.update_playlist(other_scope, playlist, %{})
      end
    end

    test "update_playlist/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      playlist = playlist_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Playlists.update_playlist(scope, playlist, @invalid_attrs)

      assert playlist == Playlists.get_playlist!(scope, playlist.id)
    end

    test "delete_playlist/2 deletes the playlist" do
      scope = user_scope_fixture()
      playlist = playlist_fixture(scope)
      assert {:ok, %Playlist{}} = Playlists.delete_playlist(scope, playlist)
      assert_raise Ecto.NoResultsError, fn -> Playlists.get_playlist!(scope, playlist.id) end
    end

    test "delete_playlist/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      playlist = playlist_fixture(scope)
      assert_raise MatchError, fn -> Playlists.delete_playlist(other_scope, playlist) end
    end

    test "change_playlist/2 returns a playlist changeset" do
      scope = user_scope_fixture()
      playlist = playlist_fixture(scope)
      assert %Ecto.Changeset{} = Playlists.change_playlist(scope, playlist)
    end
  end

  describe "playlist_tracks" do
    alias CrateStation.Playlists.PlaylistTrack

    import CrateStation.AccountsFixtures, only: [user_scope_fixture: 0]
    import CrateStation.MusicFixtures
    import CrateStation.PlaylistsFixtures

    @invalid_attrs %{position: nil, playlist_id: nil, track_id: nil}

    test "list_playlist_tracks/1 returns all scoped playlist_tracks" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      playlist_track = playlist_track_fixture(scope)
      other_playlist_track = playlist_track_fixture(other_scope)
      assert Playlists.list_playlist_tracks(scope) == [playlist_track]
      assert Playlists.list_playlist_tracks(other_scope) == [other_playlist_track]
    end

    test "get_playlist_track!/2 returns the playlist_track with given id" do
      scope = user_scope_fixture()
      playlist_track = playlist_track_fixture(scope)
      other_scope = user_scope_fixture()
      assert Playlists.get_playlist_track!(scope, playlist_track.id) == playlist_track

      assert_raise Ecto.NoResultsError, fn ->
        Playlists.get_playlist_track!(other_scope, playlist_track.id)
      end
    end

    test "create_playlist_track/2 with valid data creates a playlist_track" do
      scope = user_scope_fixture()
      playlist = playlist_fixture(scope)
      track = track_fixture(scope)
      valid_attrs = %{position: 42, playlist_id: playlist.id, track_id: track.id}

      assert {:ok, %PlaylistTrack{} = playlist_track} =
               Playlists.create_playlist_track(scope, valid_attrs)

      assert playlist_track.position == 42
      assert playlist_track.playlist_id == playlist.id
      assert playlist_track.track_id == track.id
      assert playlist_track.user_id == scope.user.id
    end

    test "create_playlist_track/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Playlists.create_playlist_track(scope, @invalid_attrs)
    end

    test "update_playlist_track/3 with valid data updates the playlist_track" do
      scope = user_scope_fixture()
      playlist_track = playlist_track_fixture(scope)
      update_attrs = %{position: 43}

      assert {:ok, %PlaylistTrack{} = playlist_track} =
               Playlists.update_playlist_track(scope, playlist_track, update_attrs)

      assert playlist_track.position == 43
    end

    test "update_playlist_track/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      playlist_track = playlist_track_fixture(scope)

      assert_raise MatchError, fn ->
        Playlists.update_playlist_track(other_scope, playlist_track, %{})
      end
    end

    test "update_playlist_track/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      playlist_track = playlist_track_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Playlists.update_playlist_track(scope, playlist_track, @invalid_attrs)

      assert playlist_track == Playlists.get_playlist_track!(scope, playlist_track.id)
    end

    test "delete_playlist_track/2 deletes the playlist_track" do
      scope = user_scope_fixture()
      playlist_track = playlist_track_fixture(scope)
      assert {:ok, %PlaylistTrack{}} = Playlists.delete_playlist_track(scope, playlist_track)

      assert_raise Ecto.NoResultsError, fn ->
        Playlists.get_playlist_track!(scope, playlist_track.id)
      end
    end

    test "delete_playlist_track/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      playlist_track = playlist_track_fixture(scope)

      assert_raise MatchError, fn ->
        Playlists.delete_playlist_track(other_scope, playlist_track)
      end
    end

    test "change_playlist_track/2 returns a playlist_track changeset" do
      scope = user_scope_fixture()
      playlist_track = playlist_track_fixture(scope)
      assert %Ecto.Changeset{} = Playlists.change_playlist_track(scope, playlist_track)
    end
  end
end
