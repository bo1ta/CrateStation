defmodule CrateStation.Repo.Migrations.CreatePlaylistTracks do
  use Ecto.Migration

  def change do
    create table(:playlist_tracks) do
      add :position, :integer
      add :playlist_id, references(:playlists, on_delete: :nothing)
      add :track_id, references(:tracks, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:playlist_tracks, [:user_id])

    create index(:playlist_tracks, [:playlist_id])
    create index(:playlist_tracks, [:track_id])
  end
end
