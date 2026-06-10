defmodule CrateStation.Music.Album do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          client_id: Ecto.UUID.t(),
          title: String.t(),
          year: integer() | nil,
          genre: String.t() | nil,
          duration: integer() | nil,
          user_id: integer(),
          user: CrateStation.Accounts.User.t() | Ecto.Association.NotLoaded.t(),
          artist_id: integer() | nil,
          artist: CrateStation.Music.Artist.t() | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "albums" do
    field :title, :string
    field :year, :integer
    field :genre, :string
    field :duration, :integer
    field :client_id, Ecto.UUID

    belongs_to :artist, CrateStation.Music.Artist
    belongs_to :user, CrateStation.Accounts.User

    has_many :tracks, CrateStation.Music.Track

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(album, attrs, user_scope) do
    album
    |> cast(attrs, [:title, :year, :genre, :duration, :client_id, :artist_id])
    |> validate_required([:title, :client_id])
    |> put_change(:user_id, user_scope.user.id)
  end
end
