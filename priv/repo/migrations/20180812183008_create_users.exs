defmodule OkrApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :string, null: false, primary_key: true)
      add(:user_name, :text, null: false)
      add(:active, :boolean, null: false)

      add(:family_name, :text)
      add(:given_name, :text)
      add(:middle_name, :text)
      add(:emails, {:array, :map}, default: [])
      add(:roles, {:array, :text}, default: [])
      add(:manager_id, :text)
      add(:manager_display_name, :text)
      add(:department, :text)

      timestamps(null: false)
    end
  end
end
