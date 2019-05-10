defmodule OkrApp.Repo.Migrations.CreateObjectiveLinks do
  use Ecto.Migration

  def change do
    create table(:objective_links) do
      add(:deleted_at, :utc_datetime)

      add(:source_objective_id, references(:objectives), null: false)
      add(:linked_to_objective_id, references(:objectives), null: false)

      timestamps(null: false)
    end
  end
end
