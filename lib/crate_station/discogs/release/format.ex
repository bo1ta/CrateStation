defmodule CrateStation.Discogs.Release.Format do
  use Ecto.Schema
  import Ecto.Changeset
  alias CrateStation.Discogs.Release.Format

  embedded_schema do
    field :name, :string
    field :qty, :string
    field :descriptions, {:array, :string}
  end

  @doc false
  def changeset(%Format{} = format, attrs) do
    format
    |> cast(attrs, [:name, :qty, :descriptions])
    |> validate_required([:name])
  end
end
