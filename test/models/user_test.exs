defmodule BioMonitor.UserTest do
  use BioMonitor.ModelCase

  alias BioMonitor.User

  @valid_attrs %{email: "p@p.com", first_name: "Pedro", last_name: "Perez", password: "asdasd"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with email too short" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :email, "p.com"))
    refute changeset.valid?
  end

  test "registration changeset, password_digest valid" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    assert changeset.changes.password_digest
    assert changeset.valid?
  end
  
  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
