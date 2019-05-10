defmodule OkrApp.Repo.Migrations.AddOkrs do
  use Ecto.Migration

  def change do
    create table("okrs") do
      add(:cycle_id, references(:cycles), null: false)
      add(:user_id, references(:users, type: :string))

      timestamps(null: false)
    end
  end
end
