defmodule CrateStation.Playback.PlaybackEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          client_id: Ecto.UUID.t(),
          event_type: :started | :scrobbled | :skipped | :finished,
          played_at: DateTime.t(),
          position_seconds: integer() | nil,
          duration_seconds: integer() | nil,
          context_type: :library | :playlist | :album | :radio | :search | nil,
          context_client_id: Ecto.UUID.t() | nil,
          user_id: integer(),
          user: CrateStation.Accounts.User.t() | Ecto.Association.NotLoaded.t(),
          track_id: integer(),
          track: CrateStation.Music.Track.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "playback_events" do
    field :client_id, Ecto.UUID
    field :event_type, Ecto.Enum, values: [:started, :scrobbled, :skipped, :finished]
    field :played_at, :utc_datetime
    field :position_seconds, :integer
    field :duration_seconds, :integer
    field :context_type, Ecto.Enum, values: [:library, :playlist, :album, :radio, :search]
    field :context_client_id, Ecto.UUID

    belongs_to :user, CrateStation.Accounts.User
    belongs_to :track, CrateStation.Music.Track

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(playback_event, attrs, user_scope) do
    playback_event
    |> cast(attrs, [
      :client_id,
      :event_type,
      :played_at,
      :position_seconds,
      :duration_seconds,
      :context_type,
      :context_client_id,
      :track_id
    ])
    |> validate_required([
      :event_type,
      :client_id,
      :played_at,
      :position_seconds,
      :duration_seconds,
      :track_id
    ])
    |> put_change(:user_id, user_scope.user.id)
  end
end
