defmodule BioMonitor.RoutineController do
  use BioMonitor.Web, :controller

  alias BioMonitor.Routine
  alias BioMonitor.Endpoint
  @routines_per_page "10"

  def index(conn, params) do
    {routines, rummage} =
      Routine |>
      Rummage.Ecto.rummage(%{
        "paginate" => %{
          "per_page" => @routines_per_page,
          "page" => "#{params["page"] || 1}"
        }
      })
    routines = Repo.all(routines) |> Repo.preload(:temp_ranges)
    render(conn, "index.json", routine: routines, page_info: rummage)
  end

  def create(conn, %{"routine" => routine_params}) do
    changeset = Routine.changeset(%Routine{}, routine_params)
    case Repo.insert(changeset) do
      {:ok, routine} ->
        routine = routine |> Repo.preload(:temp_ranges)
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
    routine = Repo.get!(Routine, id) |> Repo.preload(:temp_ranges)
    render(conn, "show.json", routine: routine)
  end

  def update(conn, %{"id" => id, "routine" => routine_params}) do
    routine = Repo.get!(Routine, id) |> Repo.preload(:temp_ranges)
    changeset = Routine.changeset(routine, routine_params)
    case Repo.update(changeset) do
      {:ok, routine} ->
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

  def sync_update(conn, %{"routine_id" => routine_uuid, "routine" => routine_params}) do
    with routine = Repo.get_by(Routine, uuid: routine_uuid),
      true <- routine != nil,
      changeset = Routine.changeset(routine, routine_params),
      {:ok, _routine} <- Repo.update(changeset)
    do
      conn
      |> put_status(200)
      |> render(conn, "show.json", routine: routine)
    else
      false ->
        changeset = Routine.changeset(%Routine{}, routine_params)
        case Repo.insert(changeset) do
          {:ok, routine} ->
            conn
            |> put_status(200)
            |> render(conn, "show.json", routine: routine)
          {:error, changeset} ->
            conn
            |> put_status(422)
            |> render(BioMonitor.ChangesetView, "error.json", changeset: changeset)
        end
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render(BioMonitor.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def sync_delete(conn, %{"routine_id" => routine_uuid}) do
    with routine = Repo.get_by!(Routine, uuid: routine_uuid),
      true <- routine != nil,
      {:ok, _struct} <- Repo.delete(routine)
    do
      send_resp(conn, :no_content, "")
    else
      _ ->
        send_resp(conn, :unprocessable_entity, "")
    end
  end
end
