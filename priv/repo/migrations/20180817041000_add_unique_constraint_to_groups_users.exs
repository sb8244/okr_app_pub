defmodule OkrApp.Repo.Migrations.AddUniqueConstraintToGroupsUsers do
  use Ecto.Migration

  def change do
    create(unique_index("groups_users", ["group_id", "user_id"], algorithm: :concurrently))
  end
end
