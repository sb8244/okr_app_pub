defmodule OkrApp.Repo.Migrations.AddPerformanceIndices do
  use Ecto.Migration

  def change do
    create(index("users", ["active"], algorithm: :concurrently))
    create(index("analytics_events", ["type", "inserted_at", "((metadata->>'owner_id')::text)"], algorithm: :concurrently))
    create(index("analytics_events", ["type", "inserted_at"], algorithm: :concurrently))
    create(index("objectives", ["deleted_at"], algorithm: :concurrently))
  end
end
