defmodule OkrApp.Repo.Migrations.CreateAnalyticsEvents do
  use Ecto.Migration

  def change do
    create table(:analytics_events) do
      add(:type, :string, null: false)
      add(:metadata, :map, default: %{}, null: false)

      add(:user_id, references(:users, type: :string), null: false)

      timestamps(null: false)
    end

    create(index(:analytics_events, [:type]))
  end
end
