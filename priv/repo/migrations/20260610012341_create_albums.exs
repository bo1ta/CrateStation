defmodule CrateStation.Repo.Migrations.CreateAlbums do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add :title, :string
      add :year, :integer
      add :genre, :string
      add :duration, :integer
      add :client_id, :uuid
      add :artist_id, references(:artists, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:albums, [:user_id])

    create index(:albums, [:artist_id])

    create index(:albums, [:user_id, :client_id])
  end
end
