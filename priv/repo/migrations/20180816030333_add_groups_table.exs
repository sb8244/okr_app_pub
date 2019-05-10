defmodule OkrApp.Repo.Migrations.AddGroupsTable do
  use Ecto.Migration

  def change do
    create table("groups") do
      add(:name, :text, null: false)

      timestamps(null: false)
    end
  end
end
