defmodule OkrApp.Repo.Migrations.RemoveAssociationsFromObjectives do
  use Ecto.Migration

  def change do
    alter table(:objectives) do
      remove(:cycle_id)
      remove(:user_id)
    end
  end
end
