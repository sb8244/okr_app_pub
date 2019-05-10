defmodule OkrApp.Repo.Migrations.AddTitleToCycles do
  use Ecto.Migration

  def change do
    alter table(:cycles) do
      add(:title, :text, null: false)
    end
  end
end
