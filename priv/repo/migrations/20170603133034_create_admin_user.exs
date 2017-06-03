defmodule BioMonitor.Repo.Migrations.CreateAdminUser do
  use Ecto.Migration
  use Coherence.Schema
  def change do
    create table(:admin_users) do
      add :email, :string
      add :password_hash, :string, null: false

      timestamps()
    end

  end
end
