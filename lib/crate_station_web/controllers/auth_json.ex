defmodule CrateStationWeb.AuthJSON do
  alias CrateStation.Accounts.{User, UserSession}

  def show(%{session: %UserSession{} = session}) do
    %{
      access_token: session.access_token,
      refresh_token: session.refresh_token,
      user: user_data(session.user)
    }
  end

  def show(%{user: %User{} = user}) do
    user_data(user)
  end

  defp user_data(%User{} = user) do
    %{
      public_id: user.public_id,
      email: user.email,
      confirmed_at: user.confirmed_at
    }
  end
end
