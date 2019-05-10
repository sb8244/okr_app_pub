defmodule OkrApp.Repo.Migrations.AllowNullCyclesOnObjectives do
  use Ecto.Migration

  def up do
    alter table(:objectives) do
      modify(:cycle_id, :bigint, null: true)
    end
  end

  def down do
    alter table(:objectives) do
      modify(:cycle_id, :bigint, null: false)
    end
  end
end
