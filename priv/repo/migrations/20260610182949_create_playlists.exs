defmodule CrateStation.Repo.Migrations.CreatePlaylists do
  use Ecto.Migration

  def change do
    create table(:playlists) do
      add :name, :string
      add :client_id, :uuid
      add :kind, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:playlists, [:user_id])
  end
end
