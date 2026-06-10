defmodule CrateStation.Music.Track do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          client_id: Ecto.UUID.t(),
          duration: integer() | nil,
          track_number: integer() | nil,
          disc_number: integer() | nil,
          year: integer() | nil,
          genre: String.t() | nil,
          bpm: float() | nil,
          song_key: String.t() | nil,
          play_count: integer(),
          rating: integer(),
          is_favorite: boolean(),
          last_played_at: DateTime.t(),
          imported_at: DateTime.t(),
          artist_id: integer(),
          artist: CrateStation.Music.Artist.t() | Ecto.Association.NotLoaded.t(),
          album_id: integer() | nil,
          album: CrateStation.Music.Album.t() | Ecto.Association.NotLoaded.t() | nil,
          user_id: integer(),
          user: CrateStation.Accounts.User.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "tracks" do
    field :client_id, Ecto.UUID
    field :title, :string
    field :duration, :integer
    field :track_number, :integer
    field :disc_number, :integer
    field :year, :integer
    field :genre, :string
    field :bpm, :float
    field :song_key, :string
    field :play_count, :integer, default: 0
    field :rating, :integer, default: 0
    field :is_favorite, :boolean, default: false
    field :last_played_at, :utc_datetime
    field :imported_at, :utc_datetime

    belongs_to :user, CrateStation.Accounts.User
    belongs_to :album, CrateStation.Music.Album
    belongs_to :artist, CrateStation.Music.Artist

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(track, attrs, user_scope) do
    track
    |> cast(attrs, [
      :client_id,
      :title,
      :duration,
      :track_number,
      :disc_number,
      :year,
      :genre,
      :bpm,
      :song_key,
      :play_count,
      :rating,
      :is_favorite,
      :last_played_at,
      :imported_at,
      :artist_id,
      :album_id
    ])
    |> validate_required([
      :title,
      :imported_at,
      :artist_id
    ])
    |> put_change(:user_id, user_scope.user.id)
  end
end
