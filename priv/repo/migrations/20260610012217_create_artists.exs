defmodule CrateStation.Repo.Migrations.CreateArtists do
  use Ecto.Migration

  def change do
    create table(:artists) do
      add :name, :string
      add :slug, :string
      add :client_id, :uuid
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:artists, [:user_id])
    create index(:artists, [:user_id, :client_id])
  end
end
