defmodule OkrApp.Repo.Migrations.StringToText do
  use Ecto.Migration

  def change do
    alter table(:okr_reflections) do
      modify(:reflection, :text, null: false)
    end

    alter table(:objective_assessments) do
      modify(:assessment, :text, null: false)
    end
  end
end
