defmodule CrateStation.Playback do
  @moduledoc """
  The Playback context.
  """

  import Ecto.Query, warn: false
  import CrateStation.Helpers.ClientHelpers

  alias CrateStation.Music
  alias CrateStation.Repo

  alias CrateStation.Playback.PlaybackEvent
  alias CrateStation.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any playback_event changes.

  The broadcasted messages match the pattern:

    * {:created, %PlaybackEvent{}}
    * {:updated, %PlaybackEvent{}}
    * {:deleted, %PlaybackEvent{}}

  """
  def subscribe_playback_events(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(CrateStation.PubSub, "user:#{key}:playback_events")
  end

  defp broadcast_playback_event(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(CrateStation.PubSub, "user:#{key}:playback_events", message)
  end

  @doc """
  Returns the list of playback_events.

  ## Examples

      iex> list_playback_events(scope)
      [%PlaybackEvent{}, ...]

  """
  def list_playback_events(%Scope{} = scope) do
    Repo.all_by(PlaybackEvent, user_id: scope.user.id)
  end

  @doc """
  Gets a single playback_event.

  Raises `Ecto.NoResultsError` if the Playback event does not exist.

  ## Examples

      iex> get_playback_event!(scope, 123)
      %PlaybackEvent{}

      iex> get_playback_event!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_playback_event!(%Scope{} = scope, id) do
    Repo.get_by!(PlaybackEvent, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a playback_event.

  ## Examples

      iex> create_playback_event(scope, %{field: value})
      {:ok, %PlaybackEvent{}}

      iex> create_playback_event(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_playback_event(%Scope{} = scope, attrs) do
    with {:ok, playback_event = %PlaybackEvent{}} <-
           %PlaybackEvent{}
           |> PlaybackEvent.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_playback_event(scope, {:created, playback_event})
      {:ok, playback_event}
    end
  end

  def upsert_events(%Scope{} = scope, attrs) do
    now = DateTime.utc_now(:second)

    track_id_by_client_id = client_id_to_track_id(attrs, scope)

    entries =
      Enum.map(attrs, fn attr ->
        %{
          user_id: scope.user.id,
          client_id: client_id(attr, "client_event_id"),
          event_type: event_type(attr),
          played_at: parse_utc_datetime(attr["played_at"]),
          position_seconds: attr["position_seconds"],
          duration_seconds: attr["duration_seconds"],
          context_type: context_type(attr),
          context_client_id: client_id(attr, "context_client_id"),
          track_id: Map.get(track_id_by_client_id, client_id(attr, "track_client_id")),
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(PlaybackEvent, entries,
      conflict_target: [:user_id, :client_id],
      on_conflict:
        {:replace,
         [
           :event_type,
           :played_at,
           :position_seconds,
           :duration_seconds,
           :context_type,
           :context_client_id,
           :track_id,
           :updated_at
         ]}
    )
  end

  defp event_type(%{"event_type" => event_type}), do: cast_enum!(:event_type, event_type)

  defp context_type(attrs) when not is_map_key(attrs, "context_type"), do: nil
  defp context_type(%{"context_type" => nil}), do: nil

  defp context_type(%{"context_type" => context_type}),
    do: cast_enum!(:context_type, context_type)

  defp cast_enum!(field, value) do
    PlaybackEvent.__schema__(:type, field)
    |> Ecto.Type.cast(value)
    |> case do
      {:ok, cast_value} -> cast_value
      :error -> raise ArgumentError, "invalid #{field}: #{inspect(value)}"
    end
  end

  defp client_id_to_track_id(attrs, scope) do
    attrs
    |> distinct_values("track_client_id")
    |> Music.fetch_tracks_ids(scope)
  end

  @doc """
  Updates a playback_event.

  ## Examples

      iex> update_playback_event(scope, playback_event, %{field: new_value})
      {:ok, %PlaybackEvent{}}

      iex> update_playback_event(scope, playback_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_playback_event(%Scope{} = scope, %PlaybackEvent{} = playback_event, attrs) do
    true = playback_event.user_id == scope.user.id

    with {:ok, playback_event = %PlaybackEvent{}} <-
           playback_event
           |> PlaybackEvent.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_playback_event(scope, {:updated, playback_event})
      {:ok, playback_event}
    end
  end

  @doc """
  Deletes a playback_event.

  ## Examples

      iex> delete_playback_event(scope, playback_event)
      {:ok, %PlaybackEvent{}}

      iex> delete_playback_event(scope, playback_event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_playback_event(%Scope{} = scope, %PlaybackEvent{} = playback_event) do
    true = playback_event.user_id == scope.user.id

    with {:ok, playback_event = %PlaybackEvent{}} <-
           Repo.delete(playback_event) do
      broadcast_playback_event(scope, {:deleted, playback_event})
      {:ok, playback_event}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking playback_event changes.

  ## Examples

      iex> change_playback_event(scope, playback_event)
      %Ecto.Changeset{data: %PlaybackEvent{}}

  """
  def change_playback_event(%Scope{} = scope, %PlaybackEvent{} = playback_event, attrs \\ %{}) do
    true = playback_event.user_id == scope.user.id

    PlaybackEvent.changeset(playback_event, attrs, scope)
  end
end
