defmodule OkrApp.Objectives.OkrReflection do
  use Ecto.Schema
  import Ecto.Changeset

  alias OkrApp.Objectives.{Okr}

  schema "okr_reflections" do
    field(:reflection, :string, null: false)
    field(:deleted_at, :utc_datetime)

    belongs_to(:okr, Okr)

    timestamps()
  end

  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:reflection, :okr_id])
    |> validate_required([:reflection, :okr_id])
    |> foreign_key_constraint(:okr_id)
  end

  def update_changeset(reflection = %__MODULE__{}, params) do
    reflection
    |> cast(params, [:reflection, :deleted_at])
    |> validate_required([:reflection])
  end
end
