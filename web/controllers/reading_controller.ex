defmodule BioMonitor.ReadingController do
  use BioMonitor.Web, :controller

  alias BioMonitor.Routine
  alias BioMonitor.Reading
  @readings_per_page "30"

  def index(conn, %{"routine_id" => routine_id} = params) do
    with routine = Repo.get(Routine, routine_id),
      true <- routine != nil
    do
      routine = Repo.preload(routine, :readings)
      render(conn, "index.json", readings: routine.readings)
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
