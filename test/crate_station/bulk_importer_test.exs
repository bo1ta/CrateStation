defmodule CrateStation.Sync.BulkImporterTest do
  use CrateStation.DataCase

  import Ecto.Query
  import CrateStation.AccountsFixtures, only: [user_scope_fixture: 0]

  alias CrateStation.Sync.BulkImporter
  alias CrateStation.Music.{Album, Artist, Track}
  alias CrateStation.Repo

  describe "upsert_artists/2" do
    test "inserts and updates artists scoped by user and client_id" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      client_id = Ecto.UUID.generate()

      assert {1, nil} =
               BulkImporter.upsert_artists(scope, [
                 %{"client_id" => client_id, "name" => "Boards of Canada", "slug" => "boc"}
               ])

      artist = Repo.get_by!(Artist, user_id: scope.user.id, client_id: client_id)
      assert artist.name == "Boards of Canada"
      assert artist.slug == "boc"

      assert {1, nil} =
               BulkImporter.upsert_artists(scope, [
                 %{"client_id" => client_id, "name" => "BoC", "slug" => "boards"}
               ])

      assert Repo.aggregate(from(a in Artist, where: a.user_id == ^scope.user.id), :count) == 1
      artist = Repo.get_by!(Artist, user_id: scope.user.id, client_id: client_id)
      assert artist.name == "BoC"
      assert artist.slug == "boards"

      assert {1, nil} =
               BulkImporter.upsert_artists(other_scope, [
                 %{"client_id" => client_id, "name" => "Other Library Artist", "slug" => "other"}
               ])

      assert Repo.get_by!(Artist, user_id: other_scope.user.id, client_id: client_id).name ==
               "Other Library Artist"
    end
  end

  describe "upsert_albums/2" do
    test "inserts and updates albums with artist associations resolved by client_id" do
      scope = user_scope_fixture()
      artist_client_id = Ecto.UUID.generate()
      album_client_id = Ecto.UUID.generate()

      BulkImporter.upsert_artists(scope, [
        %{"client_id" => artist_client_id, "name" => "Nala Sinephro", "slug" => "nala-sinephro"}
      ])

      artist = Repo.get_by!(Artist, user_id: scope.user.id, client_id: artist_client_id)

      assert {1, nil} =
               BulkImporter.upsert_albums(scope, [
                 %{
                   "client_id" => album_client_id,
                   "title" => "Space 1.8",
                   "year" => 2021,
                   "genre" => "jazz",
                   "artist_client_id" => artist_client_id
                 }
               ])

      album = Repo.get_by!(Album, user_id: scope.user.id, client_id: album_client_id)
      assert album.title == "Space 1.8"
      assert album.year == 2021
      assert album.genre == "jazz"
      assert album.artist_id == artist.id

      assert {1, nil} =
               BulkImporter.upsert_albums(scope, [
                 %{
                   "client_id" => album_client_id,
                   "title" => "Space 1.8 Remastered",
                   "year" => 2022,
                   "genre" => "ambient jazz",
                   "artist_client_id" => artist_client_id
                 }
               ])

      assert Repo.aggregate(from(a in Album, where: a.user_id == ^scope.user.id), :count) == 1
      album = Repo.get_by!(Album, user_id: scope.user.id, client_id: album_client_id)
      assert album.title == "Space 1.8 Remastered"
      assert album.year == 2022
      assert album.genre == "ambient jazz"
      assert album.artist_id == artist.id
    end
  end

  describe "upsert_tracks/2" do
    test "inserts and updates tracks with album and artist associations resolved by client_id" do
      scope = user_scope_fixture()
      artist_client_id = Ecto.UUID.generate()
      album_client_id = Ecto.UUID.generate()
      track_client_id = Ecto.UUID.generate()

      BulkImporter.upsert_artists(scope, [
        %{
          "client_id" => artist_client_id,
          "name" => "Floating Points",
          "slug" => "floating-points"
        }
      ])

      BulkImporter.upsert_albums(scope, [
        %{
          "client_id" => album_client_id,
          "title" => "Promises",
          "year" => 2021,
          "genre" => "electronic",
          "artist_client_id" => artist_client_id
        }
      ])

      artist = Repo.get_by!(Artist, user_id: scope.user.id, client_id: artist_client_id)
      album = Repo.get_by!(Album, user_id: scope.user.id, client_id: album_client_id)

      assert {1, nil} =
               BulkImporter.upsert_tracks(scope, [
                 %{
                   "client_id" => track_client_id,
                   "title" => "Movement 1",
                   "duration" => 410,
                   "track_number" => 1,
                   "disc_number" => 1,
                   "year" => 2021,
                   "genre" => "electronic",
                   "bpm" => 120.5,
                   "song_key" => "A",
                   "play_count" => 2,
                   "rating" => 4,
                   "is_favorite" => true,
                   "last_played_at" => ~U[2026-06-10 12:00:00Z],
                   "imported_at" => ~U[2026-06-09 12:00:00Z],
                   "artist_client_id" => artist_client_id,
                   "album_client_id" => album_client_id
                 }
               ])

      track = Repo.get_by!(Track, user_id: scope.user.id, client_id: track_client_id)
      assert track.title == "Movement 1"
      assert track.duration == 410
      assert track.track_number == 1
      assert track.disc_number == 1
      assert track.year == 2021
      assert track.genre == "electronic"
      assert track.bpm == 120.5
      assert track.song_key == "A"
      assert track.play_count == 2
      assert track.rating == 4
      assert track.is_favorite
      assert track.last_played_at == ~U[2026-06-10 12:00:00Z]
      assert track.imported_at == ~U[2026-06-09 12:00:00Z]
      assert track.artist_id == artist.id
      assert track.album_id == album.id

      assert {1, nil} =
               BulkImporter.upsert_tracks(scope, [
                 %{
                   "client_id" => track_client_id,
                   "title" => "Movement I",
                   "duration" => 411,
                   "track_number" => 2,
                   "disc_number" => 1,
                   "year" => 2022,
                   "genre" => "modern classical",
                   "bpm" => 121.5,
                   "song_key" => "Bb",
                   "play_count" => 3,
                   "rating" => 5,
                   "is_favorite" => false,
                   "last_played_at" => ~U[2026-06-11 12:00:00Z],
                   "imported_at" => ~U[2026-06-10 12:00:00Z],
                   "artist_client_id" => artist_client_id,
                   "album_client_id" => album_client_id
                 }
               ])

      assert Repo.aggregate(from(t in Track, where: t.user_id == ^scope.user.id), :count) == 1
      track = Repo.get_by!(Track, user_id: scope.user.id, client_id: track_client_id)
      assert track.title == "Movement I"
      assert track.duration == 411
      assert track.track_number == 2
      assert track.year == 2022
      assert track.genre == "modern classical"
      assert track.bpm == 121.5
      assert track.song_key == "Bb"
      assert track.play_count == 3
      assert track.rating == 5
      refute track.is_favorite
      assert track.last_played_at == ~U[2026-06-11 12:00:00Z]
      assert track.imported_at == ~U[2026-06-10 12:00:00Z]
      assert track.artist_id == artist.id
      assert track.album_id == album.id
    end

    test "allows tracks with missing or nil bpm" do
      scope = user_scope_fixture()
      artist_client_id = Ecto.UUID.generate()
      track_without_bpm_client_id = Ecto.UUID.generate()
      track_with_nil_bpm_client_id = Ecto.UUID.generate()

      BulkImporter.upsert_artists(scope, [
        %{
          "client_id" => artist_client_id,
          "name" => "Aphex Twin",
          "slug" => "aphex-twin"
        }
      ])

      assert {2, nil} =
               BulkImporter.upsert_tracks(scope, [
                 %{
                   "client_id" => track_without_bpm_client_id,
                   "title" => "Xtal",
                   "play_count" => 0,
                   "rating" => 0,
                   "is_favorite" => false,
                   "imported_at" => ~U[2026-06-09 12:00:00Z],
                   "artist_client_id" => artist_client_id
                 },
                 %{
                   "client_id" => track_with_nil_bpm_client_id,
                   "title" => "Tha",
                   "bpm" => nil,
                   "play_count" => 0,
                   "rating" => 0,
                   "is_favorite" => false,
                   "imported_at" => ~U[2026-06-09 12:00:00Z],
                   "artist_client_id" => artist_client_id
                 }
               ])

      track_without_bpm =
        Repo.get_by!(Track, user_id: scope.user.id, client_id: track_without_bpm_client_id)

      track_with_nil_bpm =
        Repo.get_by!(Track, user_id: scope.user.id, client_id: track_with_nil_bpm_client_id)

      assert track_without_bpm.bpm == nil
      assert track_with_nil_bpm.bpm == nil
    end
  end

  describe "upsert_events/2" do
    import CrateStation.MusicFixtures, only: [track_fixture: 1, track_fixture: 2]

    alias CrateStation.Playback
    alias CrateStation.Playback.PlaybackEvent

    test "upserts events scoped by user and client event id" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      track = track_fixture(scope)
      other_track = track_fixture(other_scope, %{client_id: track.client_id})
      client_event_id = Ecto.UUID.generate()
      context_client_id = Ecto.UUID.generate()

      assert {1, nil} =
               BulkImporter.upsert_playback_events(scope, [
                 %{
                   "client_event_id" => String.upcase(client_event_id),
                   "event_type" => "started",
                   "played_at" => "2026-06-11T22:30:28Z",
                   "position_seconds" => 0,
                   "duration_seconds" => 324,
                   "context_type" => "playlist",
                   "context_client_id" => String.upcase(context_client_id),
                   "track_client_id" => String.upcase(track.client_id)
                 }
               ])

      playback_event =
        Repo.get_by!(PlaybackEvent, user_id: scope.user.id, client_id: client_event_id)

      assert playback_event.event_type == :started
      assert playback_event.played_at == ~U[2026-06-11 22:30:28Z]
      assert playback_event.position_seconds == 0
      assert playback_event.duration_seconds == 324
      assert playback_event.context_type == :playlist
      assert playback_event.context_client_id == context_client_id
      assert playback_event.track_id == track.id

      assert {1, nil} =
               BulkImporter.upsert_playback_events(scope, [
                 %{
                   "client_event_id" => client_event_id,
                   "event_type" => "finished",
                   "played_at" => "2026-06-11T22:35:52Z",
                   "position_seconds" => 324,
                   "duration_seconds" => 324,
                   "track_client_id" => track.client_id
                 }
               ])

      assert [updated_playback_event] = Playback.list_playback_events(scope)
      assert updated_playback_event.id == playback_event.id
      assert updated_playback_event.event_type == :finished
      assert updated_playback_event.played_at == ~U[2026-06-11 22:35:52Z]
      assert updated_playback_event.context_type == nil
      assert updated_playback_event.context_client_id == nil

      assert {1, nil} =
               BulkImporter.upsert_playback_events(other_scope, [
                 %{
                   "client_event_id" => client_event_id,
                   "event_type" => "skipped",
                   "played_at" => "2026-06-11T22:31:00Z",
                   "position_seconds" => 30,
                   "duration_seconds" => 324,
                   "context_type" => "search",
                   "context_client_id" => nil,
                   "track_client_id" => other_track.client_id
                 }
               ])

      other_track_id = other_track.id

      assert [%PlaybackEvent{event_type: :skipped, track_id: ^other_track_id}] =
               Playback.list_playback_events(other_scope)
    end
  end
end
