defmodule CrateStation.Repo.Migrations.CreateTracks do
  use Ecto.Migration

  def change do
    create table(:tracks) do
      add :title, :string
      add :duration, :integer
      add :track_number, :integer
      add :disc_number, :integer
      add :year, :integer
      add :genre, :integer
      add :bpm, :float
      add :song_key, :string
      add :play_count, :integer
      add :rating, :integer
      add :is_favorite, :boolean, default: false, null: false
      add :last_played_at, :utc_datetime
      add :imported_at, :utc_datetime
      add :client_id, :uuid
      add :artist_id, references(:artists, on_delete: :nothing)
      add :album_id, references(:albums, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:tracks, [:user_id])
    create index(:tracks, [:user_id, :client_id])

    create index(:tracks, [:artist_id])
    create index(:tracks, [:album_id])
  end
end
