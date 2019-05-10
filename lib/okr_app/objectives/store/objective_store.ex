defmodule OkrApp.Objectives.ObjectiveStore do
  import Ecto.Query
  alias OkrApp.Objectives.{Objective, ObjectiveLink}
  alias OkrApp.Repo

  use OkrApp.Store.SimpleEctoStore, schema: Objective, only: [:find, :create, :update, :delete]

  def link_objectives(source_id, linked_id) do
    ObjectiveLink.changeset(%{source_objective_id: source_id, linked_to_objective_id: linked_id})
    |> Repo.insert(on_conflict: :nothing)
    |> case do
      {:ok, %{id: nil}} ->
        {:ok, refetch_objective_link(source_id, linked_id)}

      rest ->
        rest
    end
  end

  def unlink_objectives(linking_id) do
    with {:find, %ObjectiveLink{} = linking} <- {:find, Repo.get(ObjectiveLink, linking_id)} do
      ObjectiveLink.update_changeset(linking, %{deleted_at: DateTime.utc_now()})
      |> Repo.update()
    else
      {:find, nil} -> {:error, :not_found}
    end
  end

  defp refetch_objective_link(source_id, linked_id) do
    from(
      l in ObjectiveLink,
      where: l.source_objective_id == ^source_id and l.linked_to_objective_id == ^linked_id and is_nil(l.deleted_at)
    )
    |> Repo.one!()
  end
end
