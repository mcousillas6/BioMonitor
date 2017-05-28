defmodule BioMonitor.AuthenticationTest do
  use BioMonitor.ConnCase
  alias BioMonitor.{Authentication, Repo, User, Session}
  @opts Authentication.init([])
  @user_attrs %{email: "p@p.com", first_name: "Pedro", last_name: "Perez", password: "asdasd"}

  def put_auth_token_in_header(conn, token) do
    put_req_header(conn, "access-token", token)
  end

  test "finds the user by token", %{conn: conn} do
    user_changeset = User.registration_changeset(%User{}, @user_attrs)
    user = Repo.insert!(user_changeset)
    session = Repo.insert!(%Session{token: "123", user_id: user.id})

    conn = conn
    |> put_auth_token_in_header(session.token)
    |> Authentication.call(@opts)
    assert conn.assigns.current_user
  end

  test "invalid token", %{conn: conn} do
    conn = conn
    |> put_auth_token_in_header("foo")
    |> Authentication.call(@opts)

    assert conn.status == 401
    assert conn.halted
  end

  test "no token", %{conn: conn} do
    conn = Authentication.call(conn, @opts)
    assert conn.status == 401
    assert conn.halted
  end
end