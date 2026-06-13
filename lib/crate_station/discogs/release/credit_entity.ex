defmodule CrateStation.Discogs.Release.CreditEntity do
  use Ecto.Schema
  import Ecto.Changeset
  alias CrateStation.Discogs.Release.CreditEntity

  embedded_schema do
    field :discogs_id, :integer
    field :name, :string
    field :catno, :string
    field :entity_type, :string
    field :entity_type_name, :string
    field :resource_url, :string
  end

  @doc false
  def changeset(%CreditEntity{} = credit_entity, attrs) do
    credit_entity
    |> cast(attrs, [:discogs_id, :name, :catno, :entity_type, :entity_type_name, :resource_url])
    |> validate_required([:discogs_id, :name])
  end
end
