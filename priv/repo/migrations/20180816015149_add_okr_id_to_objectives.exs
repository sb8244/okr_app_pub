defmodule OkrApp.Repo.Migrations.AddOkrIdToObjectives do
  use Ecto.Migration

  def change do
    alter table(:objectives) do
      add(:okr_id, references(:okrs), null: false)
    end
  end
end
