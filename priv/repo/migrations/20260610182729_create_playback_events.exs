defmodule CrateStation.Repo.Migrations.CreatePlaybackEvents do
  use Ecto.Migration

  def change do
    create table(:playback_events) do
      add :event_type, :string
      add :played_at, :utc_datetime
      add :position_seconds, :integer
      add :duration_seconds, :integer
      add :context_type, :string
      add :context_client_id, :uuid
      add :track_id, references(:tracks, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:playback_events, [:user_id])
    create index(:playback_events, [:track_id])
  end
end
