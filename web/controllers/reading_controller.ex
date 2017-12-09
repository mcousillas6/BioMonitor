defmodule BioMonitor.ReadingController do
  use BioMonitor.Web, :controller

  alias BioMonitor.Routine
  alias BioMonitor.RoutineCalculations

  def index(conn, %{"routine_id" => routine_id}) do
    with routine = Repo.get(Routine, routine_id),
      true <- routine != nil
    do
      routine = Repo.preload(routine, :readings)
      conn |> render("index.json", %{readings: routine.readings})
    else
      false ->
        conn
        |> put_status(:not_found)
        |> render(BioMonitor.ErrorView, "404.json")
      _ ->
        conn
        |> put_status(500)
        |> render(BioMonitor.ErrorView, "500.json")
    end
  end

  def calculations(conn, %{"routine_id" => routine_id}) do
    with routine = Repo.get(Routine, routine_id),
      true <- routine != nil
    do
      case routine.started_date do
        nil ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(BioMonitor.ErrorView, "error.json", message: "Este experimento no fue ejecutado todavia.")
        started_date ->
          readings = Repo.preload(routine, :readings).readings
          calculations = RoutineCalculations.build_calculations(readings, started_date)
          render(conn, "calculations.json", values: calculations)
      end
    else
      false ->
        conn
        |> put_status(:not_found)
        |> render(BioMonitor.ErrorView, "404.json")
      _ ->
        conn
        |> put_status(500)
        |> render(BioMonitor.ErrorView, "500.json")
    end
  end
end
