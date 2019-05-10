defmodule OkrApp.Repo.Migrations.AddGroupIdToOkrs do
  use Ecto.Migration

  def change do
    alter table(:okrs) do
      add(:group_id, references(:groups))
    end
  end
end
