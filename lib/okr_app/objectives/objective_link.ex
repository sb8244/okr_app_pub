defmodule OkrApp.Objectives.ObjectiveLink do
  use Ecto.Schema
  import Ecto.Changeset

  alias OkrApp.Objectives.{Objective}

  schema "objective_links" do
    field(:deleted_at, :utc_datetime)

    belongs_to(:source_objective, Objective)
    belongs_to(:linked_to_objective, Objective)

    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:source_objective_id, :linked_to_objective_id])
    |> validate_required([:source_objective_id, :linked_to_objective_id])
    |> foreign_key_constraint(:source_objective_id)
    |> foreign_key_constraint(:linked_to_objective_id)
    |> unique_constraint(:source_objective_id, name: :objective_links_source_objective_id_linked_to_objective_id_inde)
  end

  def update_changeset(params) do
    %__MODULE__{}
    |> cast(params, [:deleted_at])
  end

  def update_changeset(linking = %__MODULE__{}, params = %{}) do
    linking
    |> cast(params, [:deleted_at])
  end
end
