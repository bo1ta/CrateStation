defmodule CrateStation.PlaybackFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CrateStation.Playback` context.
  """

  @doc """
  Generate a playback_event.
  """
  def playback_event_fixture(scope, attrs \\ %{}) do
    track = CrateStation.MusicFixtures.track_fixture(scope)

    attrs =
      Enum.into(attrs, %{
        context_client_id: "7488a646-e31f-11e4-aace-600308960662",
        context_type: :library,
        duration_seconds: 42,
        event_type: :started,
        played_at: ~U[2026-06-09 18:27:00Z],
        position_seconds: 42,
        track_id: track.id
      })

    {:ok, playback_event} = CrateStation.Playback.create_playback_event(scope, attrs)
    playback_event
  end
end
