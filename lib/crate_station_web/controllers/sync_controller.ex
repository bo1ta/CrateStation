defmodule CrateStationWeb.SyncController do
  use CrateStationWeb, :controller

  alias CrateStation.Sync.BulkImporter

  action_fallback CrateStationWeb.FallbackController

  def sync_artists(conn, %{"artists" => artists}) do
    {count, _} = BulkImporter.upsert_artists(conn.assigns.current_scope, artists)
    json(conn, %{count: count})
  end

  def sync_albums(conn, %{"albums" => albums}) do
    {count, _} = BulkImporter.upsert_albums(conn.assigns.current_scope, albums)
    json(conn, %{count: count})
  end

  def sync_tracks(conn, %{"tracks" => tracks}) do
    {count, _} = BulkImporter.upsert_tracks(conn.assigns.current_scope, tracks)
    json(conn, %{count: count})
  end

  def sync_playlists(conn, %{"playlists" => playlists}) do
    {count, _} = BulkImporter.upsert_playlists(conn.assigns.current_scope, playlists)
    json(conn, %{count: count})
  end

  def replace_playlist_tracks(conn, %{"playlist_tracks" => playlist_tracks}) do
    BulkImporter.replace_playlist_tracks(conn.assigns.current_scope, playlist_tracks)
    json(conn, %{})
  end

  def sync_events(conn, %{"events" => events}) do
    {count, _} = BulkImporter.upsert_playback_events(conn.assigns.current_scope, events)
    json(conn, %{count: count})
  end
end
