defmodule OkrApp.Repo.Migrations.AddSlugToGroups do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add(:slug, :text, null: false)
    end
  end
end
