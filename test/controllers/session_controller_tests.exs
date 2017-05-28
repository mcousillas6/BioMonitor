defmodule BioMonitor.SessionControllerTest do
  use BioMonitor.ConnCase
  alias BioMonitor.Session
  alias BioMonitor.User
  @valid_attrs %{email: "p@p.com", first_name: "Pedro", last_name: "Perez", password: "asdasd"}
  @session_attrs %{email: "p@p.com", password: "asdasd"}

  setup %{conn: conn} do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    Repo.insert! changeset
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates an renders a resource when data is valid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: @session_attrs
    assert token = conn.req_header["access-token"]
    assert Repo.get_by(Session, token: token)
  end

  test "does not create a resource an renders errors when password invalid" do
    conn = post conn, session_path(conn, :create), user: Map.put(@session_attrs, :password, "other")
    assert json_response(conn, 401)["errors"] != %{}
  end

  test "does not create resource and renders errors when email is invalid", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: Map.put(@session_attrs, :email, "not@found.com")
    assert json_response(conn, 401)["errors"] != %{}
  end
end