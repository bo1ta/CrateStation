defmodule CrateStation.Playback do
  @moduledoc """
  The Playback context.
  """

  import Ecto.Query, warn: false

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
