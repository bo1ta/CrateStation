defmodule CrateStation.Playlists.PlaylistTrack do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          position: integer() | nil,
          user_id: integer(),
          user: CrateStation.Accounts.User.t() | Ecto.Association.NotLoaded.t(),
          track_id: integer(),
          track: CrateStation.Music.Track.t() | Ecto.Association.NotLoaded.t(),
          playlist_id: integer(),
          playlist: CrateStation.Playlists.Playlist.t() | Ecto.Association.NotLoaded.t()
        }

  schema "playlist_tracks" do
    field :position, :integer

    belongs_to :user, CrateStation.Accounts.User
    belongs_to :track, CrateStation.Music.Track
    belongs_to :playlist, CrateStation.Playlists.Playlist

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(playlist_track, attrs, user_scope) do
    playlist_track
    |> cast(attrs, [:position, :track_id, :playlist_id])
    |> validate_required([:position, :track_id, :playlist_id])
    |> put_change(:user_id, user_scope.user.id)
  end
end
