defmodule CrateStation.Discogs.Release.Track do
  use Ecto.Schema
  import Ecto.Changeset
  alias CrateStation.Discogs.Release.Track

  embedded_schema do
    field :title, :string
    field :position, :string
    field :duration, :string
    field :type, :string
  end

  @doc false
  def changeset(%Track{} = track, attrs) do
    track
    |> cast(attrs, [:title, :position, :duration, :type])
    |> validate_required([:title])
  end
end
