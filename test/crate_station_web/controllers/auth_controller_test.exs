defmodule CrateStationWeb.AuthControllerTest do
  use CrateStationWeb.ConnCase, async: true

  import CrateStation.AccountsFixtures

  alias CrateStation.Accounts

  test "POST /api/auth/register returns a token pair and user payload", %{conn: conn} do
    conn =
      post(conn, ~p"/api/auth/register", %{
        email: unique_user_email(),
        password: valid_user_password()
      })

    assert %{
             "data" => %{
               "access_token" => access_token,
               "refresh_token" => refresh_token,
               "user" => %{"email" => email}
             }
           } = json_response(conn, 201)

    assert is_binary(access_token)
    assert is_binary(refresh_token)
    assert String.contains?(email, "@example.com")
  end

  test "POST /api/auth/login returns unauthorized for bad credentials", %{conn: conn} do
    user = user_fixture() |> set_password()

    conn =
      post(conn, ~p"/api/auth/login", %{
        email: user.email,
        password: "wrong password"
      })

    assert %{"errors" => %{"detail" => "Invalid email or password"}} = json_response(conn, 401)
  end

  test "POST /api/auth/login returns a session for valid credentials", %{conn: conn} do
    user = user_fixture() |> set_password()

    conn =
      post(conn, ~p"/api/auth/login", %{
        email: user.email,
        password: valid_user_password()
      })

    assert %{
             "data" => %{
               "access_token" => access_token,
               "refresh_token" => refresh_token,
               "user" => %{"id" => user_id}
             }
           } = json_response(conn, 200)

    assert is_binary(access_token)
    assert is_binary(refresh_token)
    assert user_id == user.id
  end

  test "POST /api/auth/refresh rotates the refresh token", %{conn: conn} do
    user = user_fixture()
    {:ok, session} = Accounts.create_api_session(user)

    conn = post(conn, ~p"/api/auth/refresh", %{refresh_token: session.refresh_token})

    assert %{
             "data" => %{
               "access_token" => access_token,
               "refresh_token" => refresh_token
             }
           } = json_response(conn, 200)

    assert access_token != session.access_token
    assert refresh_token != session.refresh_token
  end

  test "POST /api/auth/logout revokes the refresh token", %{conn: conn} do
    user = user_fixture()
    {:ok, session} = Accounts.create_api_session(user)

    conn = post(conn, ~p"/api/auth/logout", %{refresh_token: session.refresh_token})

    assert %{"data" => %{"revoked" => true}} = json_response(conn, 200)

    assert {:error, :invalid_refresh_token} =
             Accounts.refresh_api_session(session.refresh_token)
  end

  test "GET /api/auth/me requires a bearer token", %{conn: conn} do
    conn = get(conn, ~p"/api/auth/me")

    assert %{"errors" => %{"detail" => "Authentication required"}} = json_response(conn, 401)
  end

  test "GET /api/auth/me returns the current user", %{conn: conn} do
    user = user_fixture()
    {:ok, session} = Accounts.create_api_session(user)

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> session.access_token)
      |> get(~p"/api/auth/me")

    assert %{"data" => %{"id" => user_id, "email" => email}} =
             json_response(conn, 200)

    assert user_id == user.id
    assert email == user.email
  end
end
