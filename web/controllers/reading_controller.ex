defmodule BioMonitor.ReadingController do
  use BioMonitor.Web, :controller

  alias BioMonitor.Routine
  alias BioMonitor.Reading
  @readings_per_page "30"

  def index(conn, %{"routine_id" => routine_id} = params) do
    with routine = Repo.get(Routine, routine_id),
      true <- routine != nil
    do
      query = from r in Reading,
        where: r.routine_id == ^routine_id
      {readings, rummage} =
        query |>
        Rummage.Ecto.rummage(%{
          "paginate" => %{
            "per_page" => @readings_per_page,
            "page" => "#{params["page"] || 1}"
          }
        })
      readings = Repo.all(readings)
      render(conn, "index.json", readings: readings, page_info: rummage)
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
