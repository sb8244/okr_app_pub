defmodule OkrApp.Repo.Migrations.AddDeletedToObjectivesAndKeyResults do
  use Ecto.Migration

  def change do
    alter table(:objectives) do
      add(:deleted_at, :utc_datetime)
    end

    alter table(:key_results) do
      add(:deleted_at, :utc_datetime)
    end
  end
end
