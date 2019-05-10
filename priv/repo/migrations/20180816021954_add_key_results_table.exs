defmodule OkrApp.Repo.Migrations.AddKeyResultsTable do
  use Ecto.Migration

  def change do
    create table("key_results") do
      add(:content, :text, null: false)
      add(:cancelled_at, :utc_datetime)
      add(:mid_score, :decimal, null: false, default: 0)
      add(:final_score, :decimal, null: false, default: 0)

      add(:objective_id, references(:objectives), null: false)

      timestamps(null: false)
    end
  end
end
