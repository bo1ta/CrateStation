defmodule CrateStationWeb.PlaybackControllerTest do
  use CrateStationWeb.ConnCase, async: true

  import CrateStation.AccountsFixtures
  import CrateStation.MusicFixtures

  alias CrateStation.Accounts
  alias CrateStation.Accounts.Scope
  alias CrateStation.Playback.PlaybackEvent
  alias CrateStation.Repo

  test "POST /api/playback/events upserts Swift encoded playback events", %{conn: conn} do
    user = user_fixture()
    scope = Scope.for_user(user)
    {:ok, session} = Accounts.create_api_session(user)
    track = track_fixture(scope)
    client_event_id = Ecto.UUID.generate()
    context_client_id = Ecto.UUID.generate()

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> session.access_token)
      |> post(~p"/api/playback/events", %{
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
