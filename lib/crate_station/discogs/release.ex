defmodule CrateStation.Discogs.Release do
  use Ecto.Schema
  import Ecto.Changeset

  alias CrateStation.Discogs.Release.{
    ArtistCredit,
    Community,
    CreditEntity,
    Format,
    Identifier,
    Image,
    Track,
    Video
  }

  schema "discogs_releases" do
    field :discogs_id, :integer
    field :master_id, :integer
    field :title, :string
    field :status, :string
    field :country, :string
    field :notes, :string
    field :released, :string
    field :released_formatted, :string
    field :resource_url, :string
    field :uri, :string
    field :thumb, :string
    field :master_url, :string
    field :data_quality, :string
    field :lowest_price, :float
    field :num_for_sale, :integer
    field :estimated_weight, :integer
    field :format_quantity, :integer
    field :year, :integer
    field :date_added, :string
    field :date_changed, :string
    field :genres, {:array, :string}, default: []
    field :styles, {:array, :string}, default: []
    field :series, {:array, :string}, default: []
    field :artist_ids, {:array, :integer}, default: []
    field :label_ids, {:array, :integer}, default: []

    embeds_many :artists, ArtistCredit, on_replace: :delete
    embeds_many :extraartists, ArtistCredit, on_replace: :delete
    embeds_many :companies, CreditEntity, on_replace: :delete
    embeds_many :formats, Format, on_replace: :delete
    embeds_many :identifiers, Identifier, on_replace: :delete
    embeds_many :images, Image, on_replace: :delete
    embeds_many :labels, CreditEntity, on_replace: :delete
    embeds_many :tracklist, Track, on_replace: :delete
    embeds_many :videos, Video, on_replace: :delete
    embeds_one :community, Community, on_replace: :delete

    field :fetched_at, :utc_datetime
    field :last_refresh_error, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(release, attrs) do
    release
    |> cast(attrs, [
      :discogs_id,
      :master_id,
      :title,
      :status,
      :country,
      :notes,
      :released,
      :released_formatted,
      :resource_url,
      :uri,
      :thumb,
      :master_url,
      :data_quality,
      :lowest_price,
      :num_for_sale,
      :estimated_weight,
      :format_quantity,
      :year,
      :date_added,
      :date_changed,
      :genres,
      :styles,
      :series,
      :artist_ids,
      :label_ids,
      :fetched_at,
      :last_refresh_error
    ])
    |> cast_embed(:artists)
    |> cast_embed(:extraartists)
    |> cast_embed(:companies)
    |> cast_embed(:formats)
    |> cast_embed(:identifiers)
    |> cast_embed(:images)
    |> cast_embed(:labels)
    |> cast_embed(:tracklist)
    |> cast_embed(:videos)
    |> cast_embed(:community)
    |> validate_required([
      :discogs_id,
      :title,
      :fetched_at
    ])
    |> unique_constraint(:discogs_id)
  end
end
