defmodule CrateStation.Repo.Migrations.RemoveDurationFromAlbums do
  use Ecto.Migration

  def change do
    alter table(:albums) do
      remove :duration
    end

    alter table(:tracks) do
      remove :genre
      add :genre, :string
    end
  end
end
