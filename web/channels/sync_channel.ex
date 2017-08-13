defmodule BioMonitor.SyncChannel do
  @moduledoc """
    Channel used to sync between the local monitor and this backend.
  """
  use BioMonitor.Web, :channel
  alias BioMonitor.Reading
  alias BioMonitor.Routine
  alias BioMonitor.Endpoint

  @started_msg "started"
  @stopped_msg "stopped"
  @update_msg "update"
  @status_msg "status"
  @alert_msg "error"
  @crud_error "crud_error"
  @new_routine_msg "new_routine"
  @update_routine_msg "update_routine"
  @delete_routine_msg "delete_routine"
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
      "routine_id" => _routine_id,
      "routine_uuid" => routine_uuid,
      "id" => _id,
      "temp" => temp,
      "inserted_at" => _inserted_at
    },
    socket) do
      with routine = Repo.get_by(Routine, uuid: routine_uuid),
        true <- routine != nil,
        reading <- Ecto.build_assoc(routine, :readings),
        changeset <- Reading.changeset(reading, %{routine_id: routine.id, temp: temp}),
        {:ok, reading} <- Repo.insert(changeset)
      do
        Endpoint.broadcast(@routine_channel, @update_msg, reading_to_map(reading))
        {:reply, :ok, socket}
      else
        _ -> {:reply, :error, socket}
      end
    {:reply, :ok, socket}
  end

  def handle_in(@update_routine_msg, routine_params, socket) do
    with routine = Repo.get_by(Routine, uuid: routine_params.uuid),
      true <- routine != nil,
      changeset = Routine.changeset(routine, routine_params),
      {:ok, _routine} <- Repo.update(changeset)
    do
      {:reply, :ok, socket}
    else
      {:error, _changeset} ->
        {:reply, :ok, socket}
    end
  end

  def handle_in(@delete_routine_msg, %{"uuid" => uuid}, socket) do
    with routine = Repo.get_by!(Routine, uuid: uuid),
      true <- routine != nil,
      {:ok, _struct} <- Repo.delete(routine)
    do
      {:reply, :ok, socket}
    else
      _ ->
        IO.puts("Failed to delete routine")
        {:reply, :error, socket}
    end
  end

  def handle_in(@new_routine_msg, routine_params, socket) do
    changeset = Routine.changeset(%Routine{}, routine_params)
    case Repo.insert(changeset) do
      {:ok, _routine} ->
        {:reply, :ok, socket}
      {:error, _changeset} ->
        {:reply, :ok, socket}
    end
  end


  def handle_in(@status_msg, payload, socket) do
      Endpoint.broadcast(@routine_channel, @update_msg, payload)
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

  def handle_in(@crud_error, payload, socket) do
    Endpoint.broadcast(@routine_channel, @crud_error, payload)
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
