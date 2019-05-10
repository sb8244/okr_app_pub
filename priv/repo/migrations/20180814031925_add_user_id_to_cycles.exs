defmodule OkrApp.Repo.Migrations.AddUserIdToCycles do
  use Ecto.Migration

  def change do
    alter table(:cycles) do
      add(:user_id, references(:users, type: :string), null: false)
    end
  end
end
