defmodule CrateStation.Ingest do
  alias CrateStation.Repo
  import Ecto.Query, warn: false

  alias CrateStation.Accounts.Scope
  alias CrateStation.Music.Artist

  def upsert_artists(%Scope{} = scope, attrs) when is_list(attrs) do
    now = DateTime.utc_now(:seconds)

    entries =
      Enum.map(attrs, fn attr ->
        %{
          client_id: attr["client_id"],
          name: attr["name"],
          slug: attr["slug"],
          user_id: scope.user.id,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(Artist, entries,
      conflict_target: [:user_id, :client_id],
      on_conflict: {:replace, [:name, :slug, :updated_at]}
    )
  end
end
