defmodule CrateStation.PlaybackTest do
  use CrateStation.DataCase

  alias CrateStation.Playback
  alias CrateStation.Repo

  describe "playback_events" do
    alias CrateStation.Playback.PlaybackEvent

    import CrateStation.AccountsFixtures, only: [user_scope_fixture: 0]
    import CrateStation.MusicFixtures
    import CrateStation.PlaybackFixtures

    @invalid_attrs %{
      client_id: nil,
      event_type: nil,
      played_at: nil,
      position_seconds: nil,
      duration_seconds: nil,
      context_type: nil,
      context_client_id: nil,
      track_id: nil
    }

    test "list_playback_events/1 returns all scoped playback_events" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      playback_event = playback_event_fixture(scope)
      other_playback_event = playback_event_fixture(other_scope)
      assert Playback.list_playback_events(scope) == [playback_event]
      assert Playback.list_playback_events(other_scope) == [other_playback_event]
    end

    test "get_playback_event!/2 returns the playback_event with given id" do
      scope = user_scope_fixture()
      playback_event = playback_event_fixture(scope)
      other_scope = user_scope_fixture()
      assert Playback.get_playback_event!(scope, playback_event.id) == playback_event

      assert_raise Ecto.NoResultsError, fn ->
        Playback.get_playback_event!(other_scope, playback_event.id)
      end
    end

    test "create_playback_event/2 with valid data creates a playback_event" do
      scope = user_scope_fixture()
      track = track_fixture(scope)

      valid_attrs = %{
        client_id: "d6b3f3b5-5dbf-453f-9c28-73a06780fc99",
        event_type: :started,
        played_at: ~U[2026-06-09 18:27:00Z],
        position_seconds: 42,
        duration_seconds: 42,
        context_type: :library,
        context_client_id: "7488a646-e31f-11e4-aace-600308960662",
        track_id: track.id
      }

      assert {:ok, %PlaybackEvent{} = playback_event} =
               Playback.create_playback_event(scope, valid_attrs)

      assert playback_event.event_type == :started
      assert playback_event.client_id == "d6b3f3b5-5dbf-453f-9c28-73a06780fc99"
      assert playback_event.played_at == ~U[2026-06-09 18:27:00Z]
      assert playback_event.position_seconds == 42
      assert playback_event.duration_seconds == 42
      assert playback_event.context_type == :library
      assert playback_event.context_client_id == "7488a646-e31f-11e4-aace-600308960662"
      assert playback_event.track_id == track.id
      assert playback_event.user_id == scope.user.id
    end

    test "create_playback_event/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Playback.create_playback_event(scope, @invalid_attrs)
    end

    test "update_playback_event/3 with valid data updates the playback_event" do
      scope = user_scope_fixture()
      playback_event = playback_event_fixture(scope)

      update_attrs = %{
        client_id: "23f2458b-42d8-467d-bdc7-a2fe54f3a250",
        event_type: :scrobbled,
        played_at: ~U[2026-06-10 18:27:00Z],
        position_seconds: 43,
        duration_seconds: 43,
        context_type: :playlist,
        context_client_id: "7488a646-e31f-11e4-aace-600308960668"
      }

      assert {:ok, %PlaybackEvent{} = playback_event} =
               Playback.update_playback_event(scope, playback_event, update_attrs)

      assert playback_event.event_type == :scrobbled
      assert playback_event.client_id == "23f2458b-42d8-467d-bdc7-a2fe54f3a250"
      assert playback_event.played_at == ~U[2026-06-10 18:27:00Z]
      assert playback_event.position_seconds == 43
      assert playback_event.duration_seconds == 43
      assert playback_event.context_type == :playlist
      assert playback_event.context_client_id == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_playback_event/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      playback_event = playback_event_fixture(scope)

      assert_raise MatchError, fn ->
        Playback.update_playback_event(other_scope, playback_event, %{})
      end
    end

    test "update_playback_event/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      playback_event = playback_event_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Playback.update_playback_event(scope, playback_event, @invalid_attrs)

      assert playback_event == Playback.get_playback_event!(scope, playback_event.id)
    end

    test "delete_playback_event/2 deletes the playback_event" do
      scope = user_scope_fixture()
      playback_event = playback_event_fixture(scope)
      assert {:ok, %PlaybackEvent{}} = Playback.delete_playback_event(scope, playback_event)

      assert_raise Ecto.NoResultsError, fn ->
        Playback.get_playback_event!(scope, playback_event.id)
      end
    end

    test "delete_playback_event/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      playback_event = playback_event_fixture(scope)

      assert_raise MatchError, fn ->
        Playback.delete_playback_event(other_scope, playback_event)
      end
    end

    test "change_playback_event/2 returns a playback_event changeset" do
      scope = user_scope_fixture()
      playback_event = playback_event_fixture(scope)
      assert %Ecto.Changeset{} = Playback.change_playback_event(scope, playback_event)
    end

    test "upsert_events/2 upserts Swift encoded events scoped by user and client event id" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      track = track_fixture(scope)
      other_track = track_fixture(other_scope, %{client_id: track.client_id})
      client_event_id = Ecto.UUID.generate()
      context_client_id = Ecto.UUID.generate()

      assert {1, nil} =
               Playback.upsert_events(scope, [
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
               Playback.upsert_events(scope, [
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
               Playback.upsert_events(other_scope, [
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
