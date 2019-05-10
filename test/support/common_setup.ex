defmodule OkrApp.CommonSetup do
  def with_okr(_) do
    user = Test.Factories.User.create!(%{active: false})
    cycle = Test.Factories.Cycle.create!(user: user)
    okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: user)
    {:ok, %{okr: okr}}
  end

  def with_objectives(ctx) do
    {:ok, okrs = %{okr: okr}} = with_okr(ctx)
    objective = Test.Factories.Objective.create!(%{"okr_id" => okr.id})
    objective2 = Test.Factories.Objective.create!(%{"okr_id" => okr.id})
    objective3 = Test.Factories.Objective.create!(%{"okr_id" => okr.id})

    {:ok, Map.merge(okrs, %{objective1: objective, objective2: objective2, objective3: objective3})}
  end

  def with_objective_assessment(ctx) do
    {:ok, objectives = %{objective1: %{id: id}}} = with_objectives(ctx)
    assessment = Test.Factories.ObjectiveAssessment.create!(%{"objective_id" => id})
    {:ok, Map.merge(objectives, %{assessment: assessment})}
  end

  def with_okr_reflection(ctx) do
    {:ok, okrs = %{okr: okr}} = with_okr(ctx)
    reflection = Test.Factories.OkrReflection.create!(%{"okr_id" => okr.id})
    {:ok, Map.merge(okrs, %{okr_reflection: reflection})}
  end
end
