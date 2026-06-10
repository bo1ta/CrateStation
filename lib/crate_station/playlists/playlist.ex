defmodule CrateStation.Playlists.Playlist do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          name: String.t(),
          client_id: Ecto.UUID.t(),
          kind: :regular | :smart,
          user_id: integer(),
          user: CrateStation.Accounts.User.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          playlist_tracks:
            [CrateStation.Playlists.PlaylistTrack.t()] | Ecto.Association.NotLoaded.t(),
          tracks: [CrateStation.Music.Track.t()] | Ecto.Association.NotLoaded.t()
        }

  schema "playlists" do
    field :name, :string
    field :client_id, Ecto.UUID
    field :kind, Ecto.Enum, values: [:regular, :smart]

    belongs_to :user, CrateStation.Accounts.User

    has_many :playlist_tracks, CrateStation.Playlists.PlaylistTrack
    has_many :tracks, through: [:playlist_tracks, :track]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(playlist, attrs, user_scope) do
    playlist
    |> cast(attrs, [:name, :client_id, :kind])
    |> validate_required([:name, :client_id, :kind])
    |> put_change(:user_id, user_scope.user.id)
  end
end
