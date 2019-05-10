defmodule OkrApp.Objectives.OkrPreloader do
  alias OkrApp.Repo

  import Ecto.Query

  def preload(okrs, :current_objectives_key_results_full) do
    key_results_preload =
      from(
        kr in OkrApp.Objectives.KeyResult,
        where: is_nil(kr.deleted_at),
        order_by: [asc: :id]
      )

    assessment_preload =
      from(
        assessment in OkrApp.Objectives.ObjectiveAssessment,
        where: is_nil(assessment.deleted_at)
      )

    reflection_preload =
      from(
        reflection in OkrApp.Objectives.OkrReflection,
        where: is_nil(reflection.deleted_at)
      )

    contributed_by_objective_links_preload =
      from(
        l in OkrApp.Objectives.ObjectiveLink,
        where: is_nil(l.deleted_at)
      )

    contributed_objectives_preload =
      from(
        o in OkrApp.Objectives.Objective,
        where: is_nil(o.deleted_at),
        preload: [:user, :group]
      )

    objectives_preload =
      from(
        o in OkrApp.Objectives.Objective,
        where: is_nil(o.deleted_at),
        order_by: [desc: :cancelled_at, asc: :id],
        preload: [
          contributed_by_objective_links: ^contributed_by_objective_links_preload,
          contributes_to_objective_links: ^contributed_by_objective_links_preload,
          contributes_to_objectives: ^contributed_objectives_preload,
          contributed_by_objectives: ^contributed_objectives_preload,
          key_results: ^key_results_preload,
          objective_assessment: ^assessment_preload
        ]
      )

    Repo.preload(okrs, [:group, :user, :cycle, okr_reflection: reflection_preload, objectives: objectives_preload])
  end

  def preload(okrs, :current_objectives_key_results_simple) do
    key_results_preload =
      from(
        kr in OkrApp.Objectives.KeyResult,
        where: is_nil(kr.deleted_at),
        order_by: [asc: :id]
      )

    objectives_preload =
      from(
        o in OkrApp.Objectives.Objective,
        where: is_nil(o.deleted_at),
        order_by: [desc: :cancelled_at, asc: :id],
        preload: [
          key_results: ^key_results_preload,
        ]
      )

    Repo.preload(okrs, objectives: objectives_preload)
  end
end
