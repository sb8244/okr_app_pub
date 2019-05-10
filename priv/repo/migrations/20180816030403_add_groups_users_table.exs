defmodule OkrApp.Repo.Migrations.AddGroupsUsersTable do
  use Ecto.Migration

  def change do
    create table("groups_users") do
      add(:group_id, references(:groups), null: false)
      add(:user_id, references(:users, type: :string), null: false)

      timestamps(null: false)
    end
  end
end
