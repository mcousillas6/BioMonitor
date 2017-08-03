defmodule BioMonitor.SyncChannel do
  @moduledoc """
    Channel used to sync between the local monitor and this backend.
  """
  use BioMonitor.Web, :channel
  alias BioMonitor.Reading
  alias BioMonitor.Endpoint

  @started_msg "start"
  @stopped_msg "stopped"
  @update_msg "update"
  @alert_msg "erro"
  @routine_channel "routine"

  def join("sync", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in(
    @update_msg, %{
      "routine_id" => routine_id,
      "id" => _id,
      "temp" => temp,
      "inserted_at" => _inserted_at
    },
    socket) do
    IO.puts("Received new reading for routine: #{routine_id}")
      with routine = Repo.get(Routine, routine_id),
        true <- routine != nil,
        reading <- Ecto.build_assoc(routine, :readings),
        changeset <- Reading.changeset(reading, %{routine_id: routine_id, temp: temp}),
        {:ok, reading} <- Repo.insert(changeset)
      do
        Endpoint.broadcast(@routine_channel, @update_msg, reading_to_map(reading))
        {:reply, :ok, socket}
      else
        _ -> {:reply, :error, socket}
      end
    {:reply, :ok, socket}
  end

  def handle_in(@alert_msg, payload, socket) do
    Endpoint.broadcast(@routine_channel, @alert_msg, payload)
    {:reply, :ok, socket}
  end

  def handle_in(@started_msg, routine, socket) do
    Endpoint.broadcast(@routine_channel, @started_msg, routine)
    {:reply, :ok, socket}
  end

  def handle_in(@stopped_msg, routine, socket) do
    Endpoint.broadcast(@routine_channel, @stopped_msg, routine)
    {:reply, :ok, socket}
  end

  def handle_out(@started_msg, routine, socket) do
    push socket, @started_msg, routine
    {:noreply, socket}
  end

  def handle_out(@stopped_msg, routine, socket) do
    push socket, @stopped_msg, routine
    {:noreply, socket}
  end

  # TODO: Add basic secret key auth for this channel
  defp authorized?(_payload) do
    true
  end

  defp reading_to_map(reading) do
    %{
      routine_id: reading.routine_id,
      id: reading.id,
      temp: reading.temp,
      inserted_at: reading.inserted_at
    }
  end
end
