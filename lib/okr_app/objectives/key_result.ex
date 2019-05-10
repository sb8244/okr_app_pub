defmodule OkrApp.Objectives.KeyResult do
  @moduledoc """
  KeyResult are the ways that an objective will be completed.

  They are scored by hand, without any fancy algorithms. Just 0 -> 1 on a decimal
  scale.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias OkrApp.Objectives.{Objective}

  schema "key_results" do
    field(:content, :string, null: false)
    field(:cancelled_at, :utc_datetime)
    field(:deleted_at, :utc_datetime)
    field(:mid_score, :decimal, null: false, default: 0)
    field(:final_score, :decimal, null: false, default: 0)

    belongs_to(:objective, Objective)

    timestamps()
  end

  def create_changeset(params = %{}) do
    %__MODULE__{}
    |> cast(params, [:content, :objective_id, :cancelled_at, :mid_score, :final_score])
    |> validate_required([:content, :objective_id])
    |> foreign_key_constraint(:objective_id)
    |> common_validations()
  end

  def update_changeset(kr = %__MODULE__{}, params = %{}) do
    changeset =
      kr
      |> cast(params, [:content, :cancelled_at, :deleted_at, :mid_score, :final_score])
      |> common_validations()

    if Map.has_key?(changeset.changes, :content) do
      validate_required(changeset, [:content])
    else
      changeset
    end
  end

  defp common_validations(changeset) do
    changeset
    |> validate_number(:mid_score, greater_than_or_equal_to: 0, less_than_or_equal_to: 1, message: "must be 0.0 -> 1.0")
    |> validate_number(:final_score, greater_than_or_equal_to: 0, less_than_or_equal_to: 1, message: "must be 0.0 -> 1.0")
  end
end
