require IEx
defmodule BioMonitor.UserControllerTest do
  use BioMonitor.ConnCase

  alias BioMonitor.{Repo, User, Session}
  @valid_attrs %{email: "p@p.com", first_name: "Pedro", last_name: "Perez", password: "asdasd"}
  @invalid_attrs %{email: "p.com"}

  setup (%{conn: conn}) do
    conn
    |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    {conn, _user} = create_auth_user(conn)
    conn = get conn, user_path(conn, :index)
    assert length(json_response(conn, 200)["users"]) == 1
  end

  test "shows chosen resource", %{conn: conn} do
    {conn, user} = create_auth_user(conn)
    conn = get conn, user_path(conn, :show, user)
    assert json_response(conn, 200)["user"] == %{
      "id" => user.id,
      "first_name" => user.first_name,
      "last_name" => user.last_name,
      "email" => user.email,
    }
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    {conn, _user} = create_auth_user(conn)
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert json_response(conn, 201)["user"]["id"]
    assert Repo.get_by(User, Map.drop(@valid_attrs, [:password]))
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    {conn, user} = create_auth_user(conn)
    conn = put conn, user_path(conn, :update, user), user: @valid_attrs
    assert json_response(conn, 200)["user"]["id"]
    assert Repo.get_by(User, Map.drop(@valid_attrs, [:password]))
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    {conn, user} = create_auth_user(conn)
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    {conn, user} = create_auth_user(conn)
    conn = delete conn, user_path(conn, :delete, user)
    assert response(conn, 204)
    refute Repo.get(User, user.id)
  end

  defp create_auth_user(conn) do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    user = Repo.insert! changeset
    session = Repo.insert!(%Session{token: "123", user_id: user.id})
    conn = conn
    |> put_req_header("access-token", session.token)
    {conn, user}
  end
end
