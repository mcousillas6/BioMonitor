defmodule BioMonitor.LogEntryTest do
  use BioMonitor.ModelCase

  alias BioMonitor.LogEntry

  @valid_attrs %{description: "some content", type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = LogEntry.changeset(%LogEntry{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = LogEntry.changeset(%LogEntry{}, @invalid_attrs)
    refute changeset.valid?
  end
end
