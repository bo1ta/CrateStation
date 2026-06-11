defmodule CrateStationWeb.PlaybackController do
  use CrateStationWeb, :controller
  alias CrateStation.Playback

  action_fallback CrateStationWeb.FallbackController

  def playback_event(conn, %{"event" => event}) do
    with {:ok, _event} <- Playback.upsert_event(conn.assigns.current_scope, event) do
      json(conn, %{})
    end
  end
end
