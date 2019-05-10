defmodule OkrApp.Repo.Migrations.AddPerformanceIndicesV2 do
  use Ecto.Migration

  def change do
    create(index("users", ["active", "user_name"], algorithm: :concurrently))
    create(index("okrs", ["user_id"], algorithm: :concurrently))
    create(index("objectives", ["okr_id"], algorithm: :concurrently))
    create(index("objective_links", ["source_objective_id"], algorithm: :concurrently))
    create(index("objective_links", ["linked_to_objective_id"], algorithm: :concurrently))
    create(index("key_results", ["objective_id"], algorithm: :concurrently))
  end
end
