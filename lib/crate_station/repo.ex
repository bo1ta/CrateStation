defmodule CrateStation.Repo do
  use Ecto.Repo,
    otp_app: :crate_station,
    adapter: Ecto.Adapters.Postgres
end
