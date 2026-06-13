defmodule CrateStation.Discogs.Release.ArtistCredit do
  use Ecto.Schema
  import Ecto.Changeset
  alias CrateStation.Discogs.Release.ArtistCredit

  embedded_schema do
    field :discogs_id, :integer
    field :name, :string
    field :anv, :string
    field :role, :string
    field :join, :string
    field :tracks, :string
    field :resource_url, :string
  end

  @doc false
  def changeset(%ArtistCredit{} = artist_credit, attrs) do
    artist_credit
    |> cast(attrs, [:discogs_id, :name, :anv, :role, :join, :tracks, :resource_url])
    |> validate_required([:discogs_id, :name])
  end
end
