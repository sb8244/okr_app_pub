defmodule OkrApp.Objectives.KeyResultStoreTest do
  use OkrApp.DataCase, async: true
  alias OkrApp.Objectives.KeyResultStore

  describe "find/1" do
    setup :with_key_results

    test "valid key_result is found", %{key_result: key_result} do
      assert KeyResultStore.find(key_result.id) == {:ok, key_result}
    end

    test "valid key_result is an error" do
      assert KeyResultStore.find(0) == {:error, :not_found}
    end
  end

  describe "update/2" do
    setup :with_key_results

    test "the mid_score and final_score cannot go below 0 or above 1", %{key_result: key_result} do
      [:mid_score, :final_score]
      |> Enum.each(fn field ->
        # invalid
        assert {:error, %{errors: [{^field, {"must be 0.0 -> 1.0", _}}]}} = KeyResultStore.update(key_result, %{field => "-0.0000001"})
        assert {:ok, %{^field => val}} = KeyResultStore.find(key_result.id)
        assert val == Decimal.new("0.5")

        assert {:error, %{errors: [{^field, {"must be 0.0 -> 1.0", _}}]}} = KeyResultStore.update(key_result, %{field => "1.000001"})
        assert {:ok, %{^field => val}} = KeyResultStore.find(key_result.id)
        assert val == Decimal.new("0.5")

        # valid

        assert {:ok, _} = KeyResultStore.update(key_result, %{field => "1"})
        assert {:ok, %{^field => val}} = KeyResultStore.find(key_result.id)
        assert val == Decimal.new("1")

        assert {:ok, _} = KeyResultStore.update(key_result, %{field => "0"})
        assert {:ok, %{^field => val}} = KeyResultStore.find(key_result.id)
        assert val == Decimal.new("0")

        assert {:ok, _} = KeyResultStore.update(key_result, %{field => "0.01"})
        assert {:ok, %{^field => val}} = KeyResultStore.find(key_result.id)
        assert val == Decimal.new("0.01")

        assert {:ok, _} = KeyResultStore.update(key_result, %{field => "0.999"})
        assert {:ok, %{^field => val}} = KeyResultStore.find(key_result.id)
        assert val == Decimal.new("0.999")
      end)
    end
  end

  def with_key_results(_) do
    user = Test.Factories.User.create!(%{active: false})
    cycle = Test.Factories.Cycle.create!(user: user)
    okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: user)
    objective = Test.Factories.Objective.create!(%{"okr_id" => okr.id})
    key_result = Test.Factories.KeyResult.create!(%{"objective_id" => objective.id, "mid_score" => "0.5", "final_score" => "0.5"})

    {:ok, %{key_result: key_result}}
  end
end
