defmodule OkrApp.Objectives.ObjectiveAssessmentStoreTest do
  use OkrApp.DataCase, async: true
  import OkrApp.CommonSetup

  alias OkrApp.Objectives.ObjectiveAssessmentStore, as: Store

  describe "create/1" do
    setup :with_objectives

    test "a valid assessment is created", %{objective1: objective1} do
      assert {:ok, assessment} = Store.create(%{"assessment" => "Okay", "objective_id" => objective1.id})
      assert assessment.id
      assert assessment.objective_id == objective1.id
      assert assessment.assessment == "Okay"
    end

    test "'assessment' is required", %{objective1: objective1} do
      assert {:error, changeset} = Store.create(%{"assessment" => "", "objective_id" => objective1.id})

      assert changeset.errors == [
               assessment: {"can't be blank", [validation: :required]}
             ]
    end

    test "'objective_id' is required" do
      assert {:error, changeset} = Store.create(%{"assessment" => "x"})

      assert changeset.errors == [
               objective_id: {"can't be blank", [validation: :required]}
             ]

      assert {:error, changeset} = Store.create(%{"assessment" => "x", "objective_id" => 0})

      assert changeset.errors == [
               objective_id: {"does not exist", []}
             ]
    end
  end

  describe "update/2" do
    setup :with_objective_assessment

    test "assessment text can be updated", %{assessment: assessment} do
      assert {:ok, %{assessment: "Updated"}} = Store.update(assessment, %{"assessment" => "Updated"})
      assert {:ok, updated} = Store.find(assessment.id)

      assert updated.assessment == "Updated"
      assert updated.objective_id == assessment.objective_id
    end

    test "assessment text can not be made blank", %{assessment: assessment} do
      assert {:error, changeset} = Store.update(assessment, %{"assessment" => " "})

      assert changeset.errors == [
               assessment: {"can't be blank", [validation: :required]}
             ]
    end
  end
end
