defmodule OkrApp.Objectives.ObjectiveStoreTest do
  use OkrApp.DataCase, async: true

  alias OkrApp.Objectives.{ObjectiveStore}

  describe "link_objectives/2" do
    setup :with_objectives

    test "2 objectives can be linked together", %{objective1: objective1, objective2: objective2} do
      assert {:ok, linking} = ObjectiveStore.link_objectives(objective1.id, objective2.id)
      assert linking.id
      assert linking.source_objective_id == objective1.id
      assert linking.linked_to_objective_id == objective2.id

      # Verify complex associations work as expected

      linking_id = linking.id

      loaded_objective1 =
        OkrApp.Repo.preload(objective1, [
          :contributes_to_objectives,
          :contributed_by_objectives,
          :contributes_to_objective_links,
          :contributed_by_objective_links
        ])

      assert loaded_objective1.contributed_by_objectives == []
      assert loaded_objective1.contributed_by_objective_links == []
      assert loaded_objective1.contributes_to_objectives == [objective2]
      assert [%{id: ^linking_id}] = loaded_objective1.contributes_to_objective_links

      loaded_objective2 =
        OkrApp.Repo.preload(objective2, [
          :contributes_to_objectives,
          :contributed_by_objectives,
          :contributes_to_objective_links,
          :contributed_by_objective_links
        ])

      assert loaded_objective2.contributes_to_objectives == []
      assert loaded_objective2.contributes_to_objective_links == []
      assert loaded_objective2.contributed_by_objectives == [objective1]
      assert [%{id: ^linking_id}] = loaded_objective2.contributed_by_objective_links
    end

    test "re-linking returns the same linking", %{objective1: objective1, objective2: objective2} do
      assert {:ok, linking} = ObjectiveStore.link_objectives(objective1.id, objective2.id)
      assert {:ok, linking2} = ObjectiveStore.link_objectives(objective1.id, objective2.id)
      assert linking.id == linking2.id
    end

    test "an invalid objective is an error", %{objective1: objective1} do
      assert {:error, errors} = ObjectiveStore.link_objectives(objective1.id, 0)
      assert errors.errors == [linked_to_objective_id: {"does not exist", []}]
    end

    test "linking, unlinking, linking works", %{objective1: objective1, objective2: objective2} do
      assert {:ok, linking} = ObjectiveStore.link_objectives(objective1.id, objective2.id)
      assert {:ok, unlinked} = ObjectiveStore.unlink_objectives(linking.id)
      assert {:ok, linking2} = ObjectiveStore.link_objectives(objective1.id, objective2.id)

      assert linking.id == unlinked.id
      assert linking.id != linking2.id
    end
  end

  describe "unlink_objectives/2" do
    setup :with_objectives

    test "a linking can be marked deleted", %{objective1: objective1, objective2: objective2} do
      assert {:ok, linking} = ObjectiveStore.link_objectives(objective1.id, objective2.id)
      assert {:ok, unlinked} = ObjectiveStore.unlink_objectives(linking.id)
      assert unlinked.deleted_at
      assert linking.id == unlinked.id
    end

    test "an invalid link id is an error", %{objective1: objective1, objective2: objective2} do
      assert {:ok, linking} = ObjectiveStore.link_objectives(objective1.id, objective2.id)
      assert {:error, :not_found} = ObjectiveStore.unlink_objectives(0)
      assert {:ok, _} = ObjectiveStore.unlink_objectives(linking.id)
    end
  end

  def with_objectives(_) do
    user = Test.Factories.User.create!(%{active: false})
    cycle = Test.Factories.Cycle.create!(user: user)
    okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: user)
    objective = Test.Factories.Objective.create!(%{"okr_id" => okr.id})
    objective2 = Test.Factories.Objective.create!(%{"okr_id" => okr.id})
    objective3 = Test.Factories.Objective.create!(%{"okr_id" => okr.id})

    {:ok, %{objective1: objective, objective2: objective2, objective3: objective3}}
  end
end
