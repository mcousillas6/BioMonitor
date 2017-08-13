defmodule BioMonitor.RoutineTest do
  use BioMonitor.ModelCase

  alias BioMonitor.Routine

  @valid_attrs %{estimated_time_seconds: "120.5", extra_notes: "some content", medium: "some content", strain: "some content", target_density: "120.5", target_ph: "120.5", target_temp: "120.5", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Routine.changeset(%Routine{}, @valid_attrs)
    assert changeset.valid?
    assert changeset.changes[:uuid] != nil
  end

  test "changeset with invalid attributes" do
    changeset = Routine.changeset(%Routine{}, @invalid_attrs)
    refute changeset.valid?
  end
end
