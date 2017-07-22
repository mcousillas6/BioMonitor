defmodule BioMonitor.ReadingTest do
  use BioMonitor.ModelCase

  alias BioMonitor.Reading

  @valid_attrs %{co2: "120.5", density: "120.5", ph: "120.5", temp: "120.5"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Reading.changeset(%Reading{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Reading.changeset(%Reading{}, @invalid_attrs)
    refute changeset.valid?
  end
end
