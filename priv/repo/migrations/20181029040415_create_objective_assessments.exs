defmodule OkrApp.Repo.Migrations.CreateObjectiveAssessments do
  use Ecto.Migration

  def change do
    create table(:objective_assessments) do
      add(:assessment, :string, null: false)
      add(:objective_id, references(:objectives), null: false)
      add(:deleted_at, :utc_datetime)

      timestamps(null: false)
    end

    create(index(:objective_assessments, [:objective_id]))
  end
end
