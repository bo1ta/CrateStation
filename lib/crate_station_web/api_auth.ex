defmodule CrateStationWeb.APIAuth do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  alias CrateStation.Accounts
  alias CrateStation.Accounts.Scope

  def init(action), do: action

  def call(conn, :fetch_current_user) do
    case bearer_token(conn) do
      {:ok, token} ->
        case Accounts.get_user_by_access_token(token) do
          {:ok, user} ->
            conn
            |> assign(:current_user, user)
            |> assign(:current_scope, Scope.for_user(user))

          {:error, :invalid_access_token} ->
            conn
            |> assign(:current_user, nil)
            |> assign(:current_scope, nil)
        end

      :error ->
        conn
        |> assign(:current_user, nil)
        |> assign(:current_scope, nil)
    end
  end

  def call(conn, :require_authenticated_user) do
    conn = call(conn, :fetch_current_user)

    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{errors: %{detail: "Authentication required"}})
      |> halt()
    end
  end

  defp bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] when byte_size(token) > 0 -> {:ok, token}
      _ -> :error
    end
  end
end
