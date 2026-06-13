defmodule CrateStation.Discogs.Release.Community do
  use Ecto.Schema
  import Ecto.Changeset
  alias CrateStation.Discogs.Release.Community

  embedded_schema do
    field :have, :integer
    field :want, :integer
    field :status, :string
    field :data_quality, :string
    field :rating_average, :float
    field :rating_count, :integer
    field :submitter, :string
  end

  @doc false
  def changeset(%Community{} = community, attrs) do
    community
    |> cast(attrs, [
      :have,
      :want,
      :status,
      :data_quality,
      :rating_average,
      :rating_count,
      :submitter
    ])
  end
end
