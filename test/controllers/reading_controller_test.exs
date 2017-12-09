defmodule BioMonitor.ReadingControllerTest do
  use BioMonitor.ConnCase

  alias BioMonitor.Routine
  alias BioMonitor.Reading

  @routine_valid_attrs %{title: Faker.File.file_name(), estimated_time_seconds: "#{Faker.Commerce.price()}", extra_notes: Faker.File.file_name(), medium: Faker.Beer.name(), strain: Faker.Beer.malt(), target_co2: "#{Faker.Commerce.price()}", target_density: "#{Faker.Commerce.price()}", target_ph: "#{Faker.Commerce.price()}", target_temp: "#{Faker.Commerce.price()}"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    routine = Routine.changeset(%Routine{}, @routine_valid_attrs)
    |> Repo.insert!()
    conn = get conn, routine_reading_path(conn, :index, routine.id)
    assert json_response(conn, 200)["data"] == []
  end
end
