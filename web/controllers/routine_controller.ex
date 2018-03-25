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
        },
        "search" => %{
          "title" => %{"assoc" => [], "search_type" => "ilike", "search_term" => params["title"]},
          "strain" => %{"assoc" => [], "search_type" => "ilike", "search_term" => params["strain"]},
          "medium" => %{"assoc" => [], "search_type" => "ilike", "search_term" => params["medium"]},
          "value" => %{"assoc" => ["tags"], "search_type" => "ilike", "search_term" => params["tag"]}
        }
      })
    routines = Repo.all(routines) |> Repo.preload([:temp_ranges, :tags])
    render(conn, "index.json", routine: routines, page_info: rummage)
  end

  def create(conn, %{"routine" => routine_params}) do
    changeset = Routine.changeset(%Routine{}, routine_params)
    case Repo.insert(changeset) do
      {:ok, routine} ->
        routine = routine |> Repo.preload([:temp_ranges, :tags])
        conn
        |> put_status(:created)
        |> render("show.json", routine: routine)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(BioMonitor.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    routine = Repo.get!(Routine, id) |> Repo.preload([:temp_ranges, :tags])
    render(conn, "show.json", routine: routine)
  end

  def update(conn, %{"id" => id, "routine" => routine_params}) do
    routine = Repo.get!(Routine, id) |> Repo.preload([:temp_ranges, :tags])
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

  def to_csv(conn, %{"routine_id" => id}) do
    routine =
      Routine
      |> Repo.get!(id)
      |> Repo.preload(:readings)

    path = "#{routine.title}_readings.csv"
    file = File.open!(Path.expand(path), [:write, :utf8])

    routine.readings
      |> CSV.encode(headers: [:temp, :ph, :substratum, :product, :biomass, :inserted_at])
      |> Enum.each(&IO.write(file, &1))

    conn = conn
      |> put_resp_header("Content-Disposition", "attachment; filename=#{path}")
      |> send_file(200, path)

    File.close(file)
    File.rm(path)
    conn
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
    with routine = Repo.get_by(Routine, uuid: routine_uuid) |> Repo.preload([:temp_ranges, :tags, :log_entries]),
      true <- routine != nil,
      changeset = Routine.changeset(routine, routine_params),
      {:ok, _routine} <- Repo.update(changeset)
    do
      conn
      |> put_status(200)
      |> render("show.json", routine: routine)
    else
      false ->
        changeset = Routine.changeset(%Routine{}, routine_params)
        case Repo.insert(changeset) do
          {:ok, routine} ->
            conn
            |> put_status(200)
            |> render("show.json", routine: routine)
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
