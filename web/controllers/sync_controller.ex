defmodule BioMonitor.SyncController do
  use BioMonitor.Web, :controller

  alias BioMonitor.Routine
  alias BioMonitor.Reading
  alias BioMonitor.Routine
  alias BioMonitor.Endpoint

  #Routine channel
  @started_msg "started"
  @stopped_msg "stopped"
  @update_msg "update"
  @alert_msg "error"
  @routine_channel "routine"
  #Sensor channel
  @sensors_channel "sensors"
  @status_msg "status"
  @error_msg "error"
  #Instructions channel
  @instructions_channel "instructions"
  @instruction "instruction"

  def new_reading(conn, params) do
    with routine = Repo.get_by(Routine, uuid: params["routine_uuid"]),
      true <- routine != nil,
      reading <- Ecto.build_assoc(routine, :readings),
      changeset <- Reading.changeset(reading, %{routine_id: routine.id, temp: params["temp"], ph: params["ph"]}),
      {:ok, reading} <- Repo.insert(changeset)
    do
      Endpoint.broadcast(@routine_channel, @update_msg, reading_to_map(routine, reading))
      send_resp(conn, :no_content, "")
    else
      _ -> send_resp(conn, :unprocessable_entity, "")
    end
  end

  def batch_reading_insert(conn, %{"routine_uuid" => uuid, "readings" => readings}) do
    case Repo.get_by(Routine, uuid: uuid) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render(BioMonitor.ErrorView, "404.json")
      routine ->
        readings
        |> Enum.each(fn reading_params ->
          Ecto.build_assoc(routine, :readings)
          |> Reading.changeset(reading_params)
          |> Repo.insert
        end)
        send_resp(conn, :no_content, "")
      end
  end

  def started_routine(conn, params) do
    Endpoint.broadcast(@routine_channel, @started_msg, params)
    case Repo.get_by(Routine, uuid: params["uuid"]) do
      nil -> IO.puts "Failed to update routine #{params["uuid"]}"
      routine -> save_routine_sart_timestamp(routine)
    end
    send_resp(conn, :no_content, "")
  end

  def stopped_routine(conn, params) do
    Endpoint.broadcast(@routine_channel, @stopped_msg, params)
    send_resp(conn, :no_content, "")
  end

  def alert(conn, params) do
    Endpoint.broadcast(@routine_channel, @alert_msg, params)
    send_resp(conn, :no_content, "")
  end

  def sensor_status(conn, params) do
    # TODO: change this to the status channel
    Endpoint.broadcast(@sensors_channel, @status_msg, params)
    send_resp(conn, :no_content, "")
  end

  def sensor_error(conn, params) do
    # TODO: change this to the status channel
    Endpoint.broadcast(@sensors_channel, @error_msg, params)
    send_resp(conn, :no_content, "")
  end

  def instruction(conn, params) do
    # TODO: send  to instruction channel
    Endpoint.broadcast(@instructions_channel, @instruction, params)
    send_resp(conn, :no_content, "")
  end

  defp reading_to_map(routine, reading) do
    %{
      routine_id: routine.id,
      routine_uuid: routine.uuid,
      id: reading.id,
      temp: reading.temp,
      ph: reading.ph,
      product: reading.product,
      biomass: reading.biomass,
      substratum: reading.substratum,
      inserted_at: reading.inserted_at
    }
  end

  defp save_routine_sart_timestamp(routine) do
    changeset = routine
    |> Routine.started_changeset(%{started: true, started_date: DateTime.utc_now})
    case Repo.update(changeset) do
      {:ok, struct} ->
        {:ok, struct}
      {:error, _changeset} ->
        IO.puts "Failed to save start stamp"
        :changeset_error
    end
  end
end
