defmodule CrateStation.Repo.Migrations.MakeClientIdUniquePerUser do
  use Ecto.Migration

  def change do
    drop_if_exists unique_index(:artists, [:client_id])
    drop_if_exists unique_index(:albums, [:client_id])
    drop_if_exists unique_index(:tracks, [:client_id])
    drop_if_exists unique_index(:playlists, [:client_id])

    drop_if_exists index(:artists, [:user_id, :client_id])
    drop_if_exists index(:albums, [:user_id, :client_id])
    drop_if_exists index(:tracks, [:user_id, :client_id])

    create unique_index(:artists, [:user_id, :client_id])
    create unique_index(:albums, [:user_id, :client_id])
    create unique_index(:tracks, [:user_id, :client_id])
    create unique_index(:playlists, [:user_id, :client_id])
  end
end
