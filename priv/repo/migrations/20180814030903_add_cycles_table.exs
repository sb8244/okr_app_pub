defmodule OkrApp.Repo.Migrations.AddCyclesTable do
  use Ecto.Migration

  def change do
    create table(:cycles) do
      add(:starts_at, :utc_datetime, null: false)
      add(:ends_at, :utc_datetime, null: false)

      timestamps(null: false)
    end
  end
end
