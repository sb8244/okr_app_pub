defmodule OkrApp.Repo.Migrations.AddPinnedToGroups do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add(:pinned, :boolean, null: false, default: false)
    end
  end
end
