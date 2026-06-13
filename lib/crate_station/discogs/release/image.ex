defmodule CrateStation.Discogs.Release.Image do
  use Ecto.Schema
  import Ecto.Changeset
  alias CrateStation.Discogs.Release.Image

  embedded_schema do
    field :uri, :string
    field :uri150, :string
    field :resource_url, :string
    field :type, :string
    field :width, :integer
    field :height, :integer
  end

  @doc false
  def changeset(%Image{} = image, attrs) do
    image
    |> cast(attrs, [:uri, :uri150, :resource_url, :type, :width, :height])
    |> validate_required([:uri])
  end
end
