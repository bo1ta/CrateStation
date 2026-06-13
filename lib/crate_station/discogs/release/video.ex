defmodule CrateStation.Discogs.Release.Video do
  use Ecto.Schema
  import Ecto.Changeset
  alias CrateStation.Discogs.Release.Video

  embedded_schema do
    field :uri, :string
    field :title, :string
    field :description, :string
    field :duration, :integer
    field :embed, :boolean, default: false
  end

  @doc false
  def changeset(%Video{} = video, attrs) do
    video
    |> cast(attrs, [:uri, :title, :description, :duration, :embed])
    |> validate_required([:uri])
  end
end
