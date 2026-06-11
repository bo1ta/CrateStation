defmodule CrateStationWeb.PlaybackControllerTest do
  use CrateStationWeb.ConnCase, async: true

  import CrateStation.AccountsFixtures
  import CrateStation.MusicFixtures

  alias CrateStation.Accounts
  alias CrateStation.Accounts.Scope

  test "POST /api/playback/event accepts an event for an existing track", %{conn: conn} do
    user = user_fixture()
    scope = Scope.for_user(user)
    {:ok, session} = Accounts.create_api_session(user)
    track = track_fixture(scope)

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> session.access_token)
      |> post(~p"/api/playback/event", %{
        "event" => %{
          "context_type" => "album",
          "duration_seconds" => 324,
          "event_type" => "started",
          "played_at" => "2026-06-11T22:30:28Z",
          "position_seconds" => 0,
          "track_client_id" => track.client_id
        }
      })

    assert %{} = json_response(conn, 200)
  end
end
