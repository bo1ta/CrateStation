defmodule CrateStation.Discogs.Release.Identifier do
  use Ecto.Schema
  import Ecto.Changeset
  alias CrateStation.Discogs.Release.Identifier

  embedded_schema do
    field :type, :string
    field :value, :string
  end

  @doc false
  def changeset(%Identifier{} = identifier, attrs) do
    identifier
    |> cast(attrs, [:type, :value])
    |> validate_required([:type, :value])
  end
end
