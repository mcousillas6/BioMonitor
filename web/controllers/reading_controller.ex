defmodule BioMonitor.ReadingController do
  use BioMonitor.Web, :controller

  alias BioMonitor.Routine

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
end
