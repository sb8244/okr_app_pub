defmodule OkrApp.Repo.Migrations.CreateUniqueObjectiveLinkIndex do
  use Ecto.Migration

  def change do
    create(unique_index("objective_links", ["source_objective_id", "linked_to_objective_id"], algorithm: :concurrently, where: "deleted_at IS NULL"))
  end
end
