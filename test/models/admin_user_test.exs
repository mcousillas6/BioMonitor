defmodule BioMonitor.AdminUserTest do
  use BioMonitor.ModelCase

  alias BioMonitor.AdminUser

  @valid_attrs %{email: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = AdminUser.changeset(%AdminUser{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = AdminUser.changeset(%AdminUser{}, @invalid_attrs)
    refute changeset.valid?
  end
end
