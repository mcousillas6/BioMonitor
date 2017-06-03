defmodule BioMonitor.AdminUser do
  use BioMonitor.Web, :model
  use Coherence.Schema

  schema "admin_users" do
    field :email, :string
    coherence_schema()

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email] ++ coherence_fields())
    |> validate_required([:email])
    |> validate_coherence(params)
  end
end
