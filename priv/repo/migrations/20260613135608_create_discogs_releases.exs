defmodule CrateStation.Repo.Migrations.CreateDiscogsReleases do
  use Ecto.Migration

  def change do
    create table(:discogs_releases) do
      add :discogs_id, :integer, null: false
      add :master_id, :integer
      add :title, :string, null: false
      add :status, :string
      add :country, :string
      add :notes, :text
      add :released, :string
      add :released_formatted, :string
      add :resource_url, :string
      add :uri, :string
      add :thumb, :string
      add :master_url, :string
      add :data_quality, :string
      add :lowest_price, :float
      add :num_for_sale, :integer
      add :estimated_weight, :integer
      add :format_quantity, :integer
      add :year, :integer
      add :date_added, :string
      add :date_changed, :string
      add :genres, {:array, :string}, null: false, default: []
      add :styles, {:array, :string}, null: false, default: []
      add :series, {:array, :string}, null: false, default: []
      add :artist_ids, {:array, :integer}, null: false, default: []
      add :label_ids, {:array, :integer}, null: false, default: []
      add :artists, :map, null: false, default: fragment("'[]'::jsonb")
      add :extraartists, :map, null: false, default: fragment("'[]'::jsonb")
      add :companies, :map, null: false, default: fragment("'[]'::jsonb")
      add :formats, :map, null: false, default: fragment("'[]'::jsonb")
      add :identifiers, :map, null: false, default: fragment("'[]'::jsonb")
      add :images, :map, null: false, default: fragment("'[]'::jsonb")
      add :labels, :map, null: false, default: fragment("'[]'::jsonb")
      add :tracklist, :map, null: false, default: fragment("'[]'::jsonb")
      add :videos, :map, null: false, default: fragment("'[]'::jsonb")
      add :community, :map
      add :fetched_at, :utc_datetime, null: false
      add :last_refresh_error, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:discogs_releases, [:discogs_id])
    create index(:discogs_releases, [:master_id])
    create index(:discogs_releases, [:artist_ids], using: :gin)
    create index(:discogs_releases, [:label_ids], using: :gin)
    create index(:discogs_releases, [:genres], using: :gin)
    create index(:discogs_releases, [:styles], using: :gin)
  end
end
