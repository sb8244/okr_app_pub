defmodule OkrApp.Objectives.ObjectiveAssessment do
  use Ecto.Schema
  import Ecto.Changeset

  alias OkrApp.Objectives.{Objective}

  schema "objective_assessments" do
    field(:assessment, :string, null: false)
    field(:deleted_at, :utc_datetime)

    belongs_to(:objective, Objective)

    timestamps()
  end

  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:assessment, :objective_id])
    |> validate_required([:assessment, :objective_id])
    |> foreign_key_constraint(:objective_id)
  end

  def update_changeset(assessment = %__MODULE__{}, params) do
    assessment
    |> cast(params, [:assessment, :deleted_at])
    |> validate_required([:assessment])
  end
end
