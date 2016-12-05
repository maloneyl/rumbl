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
end
