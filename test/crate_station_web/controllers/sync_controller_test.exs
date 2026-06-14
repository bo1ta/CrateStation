defmodule CrateStationWeb.SyncControllerTest do
  use CrateStationWeb.ConnCase, async: true

  import CrateStation.AccountsFixtures
  import CrateStation.MusicFixtures

  alias CrateStation.Accounts
  alias CrateStation.Accounts.Scope
  alias CrateStation.Sync.BulkImporter
  alias CrateStation.Music.Track
  alias CrateStation.Playlists.{Playlist, PlaylistTrack}
  alias CrateStation.Repo

  alias CrateStation.Playback.PlaybackEvent

  test "POST /api/sync/tracks/upsert upserts tracks for the authenticated user", %{conn: conn} do
    user = user_fixture()
    scope = Scope.for_user(user)
    {:ok, session} = Accounts.create_api_session(user)

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

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> session.access_token)
      |> post(~p"/api/sync/tracks/upsert", %{
        "tracks" => [
          %{
            "client_id" => String.upcase(track_client_id),
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
            "last_played_at" => "2026-06-10T12:00:00Z",
            "imported_at" => "2026-06-09T12:00:00Z",
            "artist_client_id" => String.upcase(artist_client_id),
            "album_client_id" => String.upcase(album_client_id)
          }
        ]
      })

    assert %{"count" => 1} = json_response(conn, 200)

    assert %Track{title: "Movement 1"} =
             Repo.get_by(Track, user_id: user.id, client_id: track_client_id)
  end

  test "POST /api/sync/playlists/replace-tracks replaces playlist tracks", %{conn: conn} do
    user = user_fixture()
    scope = Scope.for_user(user)
    {:ok, session} = Accounts.create_api_session(user)
    playlist_client_id = Ecto.UUID.generate()
    track = track_fixture(scope)

    BulkImporter.upsert_playlists(scope, [
      %{
        "client_id" => playlist_client_id,
        "name" => "Favorites",
        "kind" => "regular"
      }
    ])

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> session.access_token)
      |> post(~p"/api/sync/playlists/replace-tracks", %{
        "playlist_tracks" => [
          %{
            "playlist_client_id" => String.upcase(playlist_client_id),
            "tracks" => [%{"track_client_id" => String.upcase(track.client_id)}]
          }
        ]
      })

    assert %{} = json_response(conn, 200)

    playlist = Repo.get_by!(Playlist, user_id: user.id, client_id: playlist_client_id)

    assert %PlaylistTrack{} =
             Repo.get_by(PlaylistTrack,
               user_id: user.id,
               playlist_id: playlist.id,
               track_id: track.id
             )
  end

  test "POST /api/sync/events/upsert upserts Swift encoded playback events", %{conn: conn} do
    user = user_fixture()
    scope = Scope.for_user(user)
    {:ok, session} = Accounts.create_api_session(user)
    track = track_fixture(scope)
    client_event_id = Ecto.UUID.generate()
    context_client_id = Ecto.UUID.generate()

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> session.access_token)
      |> post(~p"/api/sync/events/upsert", %{
        "events" => [
          %{
            "client_event_id" => String.upcase(client_event_id),
            "event_type" => "scrobbled",
            "played_at" => "2026-06-11T22:30:28Z",
            "position_seconds" => 324,
            "duration_seconds" => 324,
            "context_type" => "library",
            "context_client_id" => String.upcase(context_client_id),
            "track_client_id" => String.upcase(track.client_id)
          }
        ]
      })

    assert %{"count" => 1} = json_response(conn, 200)

    assert %PlaybackEvent{
             event_type: :scrobbled,
             played_at: ~U[2026-06-11 22:30:28Z],
             position_seconds: 324,
             duration_seconds: 324,
             context_type: :library,
             context_client_id: ^context_client_id,
             track_id: track_id
           } = Repo.get_by!(PlaybackEvent, user_id: user.id, client_id: client_event_id)

    assert track_id == track.id
  end
end
