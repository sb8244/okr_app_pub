defmodule OkrApp.Objectives.OkrReflectionStoreTest do
  use OkrApp.DataCase, async: true
  import OkrApp.CommonSetup

  alias OkrApp.Objectives.OkrReflectionStore, as: Store

  describe "create/1" do
    setup :with_okr

    test "a valid reflection is created", %{okr: okr} do
      assert {:ok, struct} = Store.create(%{"reflection" => "Okay", "okr_id" => okr.id})
      assert struct.id
      assert struct.okr_id == okr.id
      assert struct.reflection == "Okay"
    end

    test "'reflection' is required", %{okr: okr} do
      assert {:error, changeset} = Store.create(%{"reflection" => "", "okr_id" => okr.id})

      assert changeset.errors == [
               reflection: {"can't be blank", [validation: :required]}
             ]
    end

    test "'okr_id' is required" do
      assert {:error, changeset} = Store.create(%{"reflection" => "x"})

      assert changeset.errors == [
               okr_id: {"can't be blank", [validation: :required]}
             ]

      assert {:error, changeset} = Store.create(%{"reflection" => "x", "okr_id" => 0})

      assert changeset.errors == [
               okr_id: {"does not exist", []}
             ]
    end
  end

  describe "update/2" do
    setup :with_okr_reflection

    test "reflection text can be updated", %{okr_reflection: reflection} do
      assert {:ok, %{reflection: "Updated"}} = Store.update(reflection, %{"reflection" => "Updated"})
      assert {:ok, updated} = Store.find(reflection.id)

      assert updated.reflection == "Updated"
      assert updated.okr_id == reflection.okr_id
    end

    test "reflection text can not be made blank", %{okr_reflection: reflection} do
      assert {:error, changeset} = Store.update(reflection, %{"reflection" => " "})

      assert changeset.errors == [
               reflection: {"can't be blank", [validation: :required]}
             ]
    end
  end
end
