defmodule BioMonitor.RoutineControllerTest do
  use BioMonitor.ConnCase

  alias BioMonitor.Routine
  @valid_attrs %{estimated_time_seconds: "120.5", extra_notes: "some content", medium: "some content", strain: "some content", target_density: "120.5", target_ph: "120.5", target_temp: "120.5", title: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, routine_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    routine = Repo.insert! %Routine{}
    conn = get conn, routine_path(conn, :show, routine)
    assert json_response(conn, 200)["data"] == %{"id" => routine.id,
      "title" => routine.title,
      "strain" => routine.strain,
      "medium" => routine.medium,
      "target_temp" => routine.target_temp,
      "target_ph" => routine.target_ph,
      "target_density" => routine.target_density,
      "estimated_time_seconds" => routine.estimated_time_seconds,
      "extra_notes" => routine.extra_notes}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, routine_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, routine_path(conn, :create), routine: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Routine, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, routine_path(conn, :create), routine: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    routine = Repo.insert! %Routine{}
    conn = put conn, routine_path(conn, :update, routine), routine: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Routine, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    routine = Repo.insert! %Routine{}
    conn = put conn, routine_path(conn, :update, routine), routine: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    routine = Repo.insert! %Routine{}
    conn = delete conn, routine_path(conn, :delete, routine)
    assert response(conn, 204)
    refute Repo.get(Routine, routine.id)
  end
end
