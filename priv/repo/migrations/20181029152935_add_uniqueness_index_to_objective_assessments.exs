defmodule OkrApp.Repo.Migrations.AddUniquenessIndexToObjectiveAssessments do
  use Ecto.Migration

  def change do
    create(
      unique_index("objective_assessments", ["objective_id"],
        algorithm: :concurrently,
        where: "deleted_at IS NULL",
        name: "objective_assessments_unique_per_objective_id"
      )
    )
  end
end
