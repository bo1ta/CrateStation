defmodule CrateStation.Repo.Migrations.AddPublicIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :public_id, :uuid
    end

    create index(:users, [:public_id])
  end
end
