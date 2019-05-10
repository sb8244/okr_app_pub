defmodule OkrApp.Repo.Migrations.AddObjectivesTable do
  use Ecto.Migration

  def change do
    create table("objectives") do
      add(:content, :text, null: false)
      add(:mid_score, :decimal, null: false, default: 0)
      add(:final_score, :decimal, null: false, default: 0)
      add(:cancelled_at, :utc_datetime)

      add(:cycle_id, references(:cycles), null: false)
      add(:user_id, references(:users, type: :string), null: false)

      timestamps(null: false)
    end
  end
end
