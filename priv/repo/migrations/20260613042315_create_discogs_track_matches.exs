defmodule CrateStation.Repo.Migrations.CreateDiscogsTrackMatches do
  use Ecto.Migration

  def change do
    create table(:discogs_track_matches) do
      add :status, :string, null: false, default: "pending"
      add :discogs_release_id, :integer
      add :discogs_master_id, :integer
      add :discogs_track_position, :string
      add :discogs_track_title, :string

      add :discogs_artist_ids, {:array, :integer}, null: false, default: []
      add :discogs_label_ids, {:array, :integer}, null: false, default: []

      add :confidence_score, :float
      add :match_strategy, :string
      add :match_evidence, :map, null: false, default: %{}

      add :last_attempted_at, :utc_datetime
      add :matched_at, :utc_datetime
      add :attempt_count, :integer, null: false, default: 0
      add :last_error, :text

      add :track_id, references(:tracks, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:discogs_track_matches, [:user_id, :track_id])

    create index(:discogs_track_matches, [:track_id])

    create index(:discogs_track_matches, [:user_id, :status])
    create index(:discogs_track_matches, [:discogs_release_id])
    create index(:discogs_track_matches, [:discogs_master_id])
    create index(:discogs_track_matches, [:discogs_artist_ids], using: :gin)
    create index(:discogs_track_matches, [:discogs_label_ids], using: :gin)
  end
end
