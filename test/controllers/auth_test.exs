# require IEx

defmodule Rumbl.AuthTest do
  use Rumbl.ConnCase
  alias Rumbl.Auth # gives us bypass_through helper, which lets us bypass route dispatch

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Rumbl.Router, :browser) # so we don't get 'flash/session not fetched' errors
      |> get("/") # isn't used by router; simply stored in connection
    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no curent_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user continues when the current_user exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Rumbl.User{})
      |> Auth.authenticate_user([])
    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn =
      conn
      |> Auth.login(%Rumbl.User{id: 123})
      |> send_resp(:ok, "")

    # IEx.pry (run test with iex -S mix test; change timeout in config/test.exs if needed)

    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assigns to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)
    assert conn.assigns.current_user == nil
  end
end
