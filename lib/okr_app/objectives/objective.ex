defmodule OkrApp.Objectives.Objective do
  @moduledoc """
  Objectives are high level goals that an individual wishes to complete. They are
  contained with other objectives in an Okr.

  They are scored automatically based on the completion of key results.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias OkrApp.Objectives.{KeyResult, Okr, ObjectiveAssessment, ObjectiveLink}

  schema "objectives" do
    field(:content, :string, null: false)
    field(:cancelled_at, :utc_datetime)
    field(:deleted_at, :utc_datetime)

    belongs_to(:okr, Okr)
    has_one(:user, through: [:okr, :user])
    has_one(:group, through: [:okr, :group])

    has_many(:key_results, KeyResult)
    has_one(:objective_assessment, ObjectiveAssessment)

    has_many(:contributes_to_objective_links, ObjectiveLink, foreign_key: :source_objective_id)
    has_many(:contributed_by_objective_links, ObjectiveLink, foreign_key: :linked_to_objective_id)
    has_many(:contributes_to_objectives, through: [:contributes_to_objective_links, :linked_to_objective])
    has_many(:contributed_by_objectives, through: [:contributed_by_objective_links, :source_objective])

    timestamps()
  end

  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:content, :okr_id])
    |> validate_required([:content, :okr_id])
    |> foreign_key_constraint(:okr_id)
  end

  def update_changeset(objective = %__MODULE__{}, params) do
    changeset =
      objective
      |> cast(params, [:content, :cancelled_at, :deleted_at])

    if Map.has_key?(changeset.changes, :content) do
      validate_required(changeset, [:content])
    else
      changeset
    end
  end

  def mid_score(%{key_results: key_results}) do
    key_results
    |> Enum.filter(&is_nil(&1.cancelled_at))
    |> Enum.map(& &1.mid_score)
    |> score_average()
  end

  def final_score(%{key_results: key_results}) do
    key_results
    |> Enum.filter(&is_nil(&1.cancelled_at))
    |> Enum.map(& &1.final_score)
    |> score_average()
  end

  defp score_average(scores) do
    no_score = Decimal.new(0)
    count = Decimal.new(length(scores))

    sum =
      Enum.reduce(scores, no_score, fn score, sum ->
        Decimal.add(score, sum)
      end)

    if count == no_score do
      no_score
    else
      Decimal.div(sum, count)
    end
    |> OkrApp.Objectives.round_score(:objective)
  end
end
