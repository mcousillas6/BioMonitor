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
      IO.inspect routine
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

  def calculations_to_csv(conn, %{"routine_id" => id}) do
    with routine = Repo.get(Routine, id),
      true <- routine != nil
    do
      case routine.started_date do
        nil ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(BioMonitor.ErrorView, "error.json", message: "Este experimento no fue ejecutado todavia.")
        started_date ->
          readings = Repo.preload(routine, :readings).readings
          calculations = RoutineCalculations.build_csv_calculations(readings, started_date)
          path = "#{routine.title}_calculations.csv"
          file = File.open!(Path.expand(path), [:write, :utf8])
          calculations
            |> CSV.encode(headers: [:time_in_seconds, :biomass_performance, :product_performance, :product_biomass_performance, :product_volumetric_performance, :biomass_volumetric_performance, :specific_ph_velocity, :specific_biomass_velocity, :specific_product_velocity])
            |> Enum.each(&IO.write(file, &1))

          conn = conn
            |> put_resp_header("Content-Disposition", "attachment; filename=#{path}")
            |> send_file(200, path)

          File.close(file)
          File.rm(path)
          conn
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
