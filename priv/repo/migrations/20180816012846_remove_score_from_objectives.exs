defmodule OkrApp.Repo.Migrations.RemoveScoreFromObjectives do
  use Ecto.Migration

  def change do
    alter table(:objectives) do
      remove(:mid_score)
      remove(:final_score)
    end
  end
end
