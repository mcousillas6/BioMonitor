defmodule BioMonitor.RoutineController do
  use BioMonitor.Web, :controller

  alias BioMonitor.Routine
  alias BioMonitor.Endpoint

  def index(conn, _params) do
    routines = Repo.all(Routine)
    render(conn, "index.json", routines: routines)
  end

  def create(conn, %{"routine" => routine_params}) do
    changeset = Routine.changeset(%Routine{}, routine_params)
    case Repo.insert(changeset) do
      {:ok, routine} ->
        Endpoint.broadcast("sync", "new_routine", Map.put(routine_params, :uuid, routine.uuid))
        conn
        |> put_status(:created)
        |> put_resp_header("location", routine_path(conn, :show, routine))
        |> render("show.json", routine: routine)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(BioMonitor.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    routine = Repo.get!(Routine, id)
    render(conn, "show.json", routine: routine)
  end

  def update(conn, %{"id" => id, "routine" => routine_params} = params) do
    routine = Repo.get!(Routine, id)
    changeset = Routine.changeset(routine, routine_params)
    case Repo.update(changeset) do
      {:ok, routine} ->
        Endpoint.broadcast("sync", "update_routine", Map.put(params, :uuid, routine.uuid))
        render(conn, "show.json", routine: routine)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(BioMonitor.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    routine = Repo.get!(Routine, id)
    Repo.delete!(routine)
    Endpoint.broadcast("sync", "delete_routine", %{uuid: routine.uuid})
    send_resp(conn, :no_content, "")
  end

  def stop(conn, _params) do
    Endpoint.broadcast("sync", "stopped", %{})
    send_resp(conn, :no_content, "")
  end

  def start(conn, %{"id" => id}) do
    routine = Repo.get!(Routine, id)
    Endpoint.broadcast("sync", "start", %{id: routine.id})
    render(conn, "show.json", routine: routine)
  end
end
