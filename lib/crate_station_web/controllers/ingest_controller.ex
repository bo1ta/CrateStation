defmodule CrateStationWeb.IngestController do
  use CrateStationWeb, :controller

  alias CrateStation.Ingest

  action_fallback CrateStationWeb.FallbackController

  def sync_artists(conn, %{"artists" => artists}) do
    {count, _} = Ingest.upsert_artists(conn.assigns.current_scope, artists)
    json(conn, %{count: count})
  end

  def sync_albums(conn, %{"albums" => albums}) do
    {count, _} = Ingest.upsert_albums(conn.assigns.current_scope, albums)
    json(conn, %{count: count})
  end

  def sync_tracks(conn, %{"tracks" => tracks}) do
    {count, _} = Ingest.upsert_tracks(conn.assigns.current_scope, tracks)
    json(conn, %{count: count})
  end

  def sync_playlists(conn, %{"playlists" => playlists}) do
    {count, _} = Ingest.upsert_playlists(conn.assigns.current_scope, playlists)
    json(conn, %{count: count})
  end
end
