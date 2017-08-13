defmodule BioMonitor.RoutineChannelTest do
  use BioMonitor.ChannelCase

  alias BioMonitor.RoutineChannel

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(RoutineChannel, "routine")

    {:ok, socket: socket}
  end
end
