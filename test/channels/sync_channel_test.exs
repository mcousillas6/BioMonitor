defmodule BioMonitor.SyncChannelTest do
  use BioMonitor.ChannelCase

  alias BioMonitor.SyncChannel

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(SyncChannel, "sync")

    {:ok, socket: socket}
  end
end
