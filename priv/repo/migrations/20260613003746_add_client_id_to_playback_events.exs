defmodule CrateStation.Repo.Migrations.AddClientIdToPlaybackEvents do
  use Ecto.Migration

  def change do
    alter table(:playback_events) do
      add :client_id, :uuid
    end

    create unique_index(:playback_events, [:user_id, :client_id])
  end
end
