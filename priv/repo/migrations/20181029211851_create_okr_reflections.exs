defmodule OkrApp.Repo.Migrations.CreateOkrReflections do
  use Ecto.Migration

  def change do
    create table(:okr_reflections) do
      add(:reflection, :string, null: false)
      add(:okr_id, references(:okrs), null: false)
      add(:deleted_at, :utc_datetime)

      timestamps(null: false)
    end

    create(
      unique_index("okr_reflections", ["okr_id"],
        algorithm: :concurrently,
        where: "deleted_at IS NULL",
        name: "okr_reflections_unique_per_okr_id"
      )
    )
  end
end
