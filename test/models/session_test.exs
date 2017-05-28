defmodule BioMonitor.SessionTest do
  use BioMonitor.ModelCase

  alias BioMonitor.Session

  @valid_attrs %{user_id: "1"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Session.changeset(%Session{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Session.changeset(%Session{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "create_changeset with valid attribuites" do
    changeset = Session.registration_changeset(%Session{}, @valid_attrs)
    assert changeset.changes.token
    assert changeset.valid?
  end

  test "create_changeset with invalid attribuites" do
    changeset = Session.registration_changeset(%Session{}, @invalid_attrs)
    refute changeset.valid?
  end
end
