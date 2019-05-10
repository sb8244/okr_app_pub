defmodule OkrApp.Objectives do
  alias OkrApp.Objectives.{
    CycleStore,
    KeyResultStore,
    ObjectiveStore,
    OkrPreloader,
    OkrStore,
    ObjectiveAssessmentStore,
    ObjectiveLinkStore,
    OkrReflectionStore
  }

  defdelegate all_okrs(params, opts \\ []), to: OkrStore, as: :all
  defdelegate create_okr(params, list), to: OkrStore, as: :create
  defdelegate preload_okrs(okrs, type), to: OkrPreloader, as: :preload

  defdelegate all_cycles(params, opts \\ []), to: CycleStore, as: :all
  defdelegate create_cycle(params, opts), to: CycleStore, as: :create

  defdelegate find_key_result(id), to: KeyResultStore, as: :find
  defdelegate update_key_result(kr, params), to: KeyResultStore, as: :update
  defdelegate create_key_result(params), to: KeyResultStore, as: :create
  defdelegate delete_key_result(kr), to: KeyResultStore, as: :delete

  defdelegate find_objective(id), to: ObjectiveStore, as: :find
  defdelegate create_objective(params), to: ObjectiveStore, as: :create
  defdelegate update_objective(obj, params), to: ObjectiveStore, as: :update
  defdelegate delete_objective(obj), to: ObjectiveStore, as: :delete
  defdelegate link_objectives(source_id, linked_id), to: ObjectiveStore
  defdelegate unlink_objectives(linking_id), to: ObjectiveStore

  defdelegate all_objective_links(params, opts \\ []), to: ObjectiveLinkStore, as: :all

  defdelegate find_objective_assessment(id), to: ObjectiveAssessmentStore, as: :find
  defdelegate create_objective_assessment(params), to: ObjectiveAssessmentStore, as: :create
  defdelegate update_objective_assessment(assessment, params), to: ObjectiveAssessmentStore, as: :update

  defdelegate find_okr_reflection(id), to: OkrReflectionStore, as: :find
  defdelegate create_okr_reflection(params), to: OkrReflectionStore, as: :create
  defdelegate update_okr_reflection(struct, params), to: OkrReflectionStore, as: :update

  def round_score(score, :objective), do: Decimal.round(score, 2)

  def round_score(score, :key_result), do: Decimal.round(score, 1)
end
