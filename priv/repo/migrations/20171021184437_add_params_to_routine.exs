defmodule BioMonitor.Repo.Migrations.AddParamsToRoutine do
  use Ecto.Migration

  def change do
    alter table(:routines) do
      add :started, :boolean, default: false
      add :started_date, :naive_datetime
      add :temp_tolerance, :float, default: 1.0
      add :ph_tolerance, :float, default: 0.0
      add :balance_ph, :boolean, default: false
      add :loop_delay, :integer, default: 2_000
      add :trigger_after, :integer
      add :trigger_for, :integer, default: 60_000
    end
  end
end
