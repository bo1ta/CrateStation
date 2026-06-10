defmodule CrateStationWeb.AuthController do
  use CrateStationWeb, :controller

  alias CrateStation.Accounts.UserToken
  alias CrateStation.Accounts

  action_fallback CrateStationWeb.FallbackController

  def register(conn, %{"email" => _email, "password" => _password} = params) do
    with {:ok, user} <- Accounts.register_user_with_password(params),
         {:ok, session} <- Accounts.create_api_session(user) do
      conn
      |> put_status(:created)
      |> render(:show, session: session)
    end
  end

  def login(conn, %{"email" => _email, "password" => _password} = attrs) do
    with {:ok, user} <- Accounts.login_user(attrs),
         {:ok, session} <- Accounts.create_api_session(user) do
      render(conn, :show, session: session)
    end
  end

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, session} <- Accounts.refresh_api_session(refresh_token) do
      render(conn, :show, session: session)
    end
  end

  def refresh(_conn, _params), do: {:error, :invalid_refresh_token}

  def logout(conn, %{"refresh_token" => refresh_token}) do
    with :ok <- UserToken.revoke_refresh_token(refresh_token) do
      json(conn, %{data: %{revoked: true}})
    end
  end

  def logout(_conn, _params), do: {:error, :invalid_refresh_token}

  def me(conn, _params) do
    render(conn, :show, user: conn.assigns.current_user)
  end
end
