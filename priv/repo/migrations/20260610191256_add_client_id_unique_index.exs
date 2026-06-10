defmodule CrateStation.Repo.Migrations.AddClientIdUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:playlists, :client_id)
    create unique_index(:albums, :client_id)
    create unique_index(:artists, :client_id)
    create unique_index(:tracks, :client_id)
  end
end
