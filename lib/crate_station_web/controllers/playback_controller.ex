defmodule CrateStationWeb.PlaybackController do
  use CrateStationWeb, :controller
  alias CrateStation.Playback

  action_fallback CrateStationWeb.FallbackController

  def playback_events(conn, %{"events" => events}) do
    {count, _} = Playback.upsert_events(conn.assigns.current_scope, events)
    json(conn, %{count: count})
  end
end
