defmodule Rumbl.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Phoenix.Controller # for things like put_flash and redirect
  alias Rumbl.Router.Helpers # NOT alias, because we'll use Rumbl.Auth in router => circular dependency

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)

    cond do
      # controversial; make implementation more testable without mocks or any scaffolding
      user = conn.assigns[:current_user] ->
        conn
      user = user_id && repo.get(Rumbl.User, user_id) ->
        assign(conn, :current_user, user) # the Plug.Conn struct has a field called assigns
      true ->
        assign(conn, :current_user, nil)
    end
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page.")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true) # tells Plug to send session cookie back to client with different identifier
  end

  def login_by_username_and_pass(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Rumbl.User, username: username)

    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw() # simulate password check with variable timing; hardens against timing attack
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true) # drop the whole session

    # or, to keep the session but delete only the user ID info:
    # delete_session(conn, :user_id)
  end
end
