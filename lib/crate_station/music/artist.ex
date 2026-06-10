defmodule CrateStation.Music.Artist do
  use Ecto.Schema
  import Ecto.Changeset

  import CrateStation.Helpers.Schema

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          slug: String.t(),
          client_id: Ecto.UUID.t(),
          user_id: integer(),
          user: CrateStation.Accounts.User.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "artists" do
    field :name, :string
    field :slug, :string
    field :client_id, Ecto.UUID

    belongs_to :user, CrateStation.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(artist, attrs, user_scope) do
    artist
    |> cast(attrs, [:name, :slug, :client_id])
    |> validate_required([:name, :client_id])
    |> put_change(:user_id, user_scope.user.id)
  end
end
