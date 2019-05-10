defmodule OkrApp.ObjectivesTest do
  use OkrApp.DataCase, async: true

  alias OkrApp.Objectives
  alias Objectives.{Cycle, Objective}
  alias OkrApp.Users.{User}

  describe "create_cycle/2" do
    setup :with_cycle_params

    test "attributes are required" do
      assert {:error, changeset} = Objectives.create_cycle(%{}, user: %User{id: "no"})
      refute changeset.valid?

      assert changeset.errors == [
               title: {"can't be blank", validation: :required},
               starts_at: {"can't be blank", [validation: :required]},
               ends_at: {"can't be blank", [validation: :required]}
               # We don't know that the user is invalid until it executes
             ]
    end

    test "a valid cycle can be created", %{valid_params: params, now: now} do
      user = Test.Factories.User.create!()

      assert {:ok, cycle = %Cycle{}} = Objectives.create_cycle(params, user: user)
      assert cycle.id
      assert cycle.starts_at == now
      assert cycle.ends_at == now
      assert cycle.user_id == user.id
    end

    test "a valid user is required", %{valid_params: params} do
      assert {:error, changeset} = Objectives.create_cycle(params, user: %User{id: "no"})
      refute changeset.valid?
      assert changeset.errors == [user_id: {"does not exist", []}]
    end
  end

  describe "create_objective/1" do
    setup :with_objective_params

    test "attributes are required" do
      assert {:error, changeset} = Objectives.create_objective(%{})
      refute changeset.valid?

      assert changeset.errors == [
               content: {"can't be blank", [validation: :required]},
               okr_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "a valid objective can be created", %{valid_params: params} do
      assert {:ok, obj = %Objective{}} = Objectives.create_objective(params)
      assert obj.id
      assert obj.content == params["content"]
    end

    test "the okr_id must be valid", %{valid_params: params} do
      assert {:error, changeset} = Objectives.create_objective(Map.put(params, "okr_id", 0))
      refute changeset.valid?

      assert changeset.errors == [
               okr_id: {"does not exist", []}
             ]
    end
  end

  describe "create_key_result/2" do
    setup :with_key_result_params

    test "attributes are required" do
      assert {:error, changeset} = Objectives.create_key_result(%{})
      refute changeset.valid?

      assert changeset.errors == [
               content: {"can't be blank", [validation: :required]},
               objective_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "a valid key result can be created", %{valid_params: params, objective: objective} do
      assert {:ok, kr} = Objectives.create_key_result(params)
      assert kr.id
      assert kr.content == params["content"]
      assert kr.objective_id == objective.id
    end

    test "the objective_id must be valid", %{valid_params: params} do
      assert {:error, changeset} = Objectives.create_key_result(Map.put(params, "objective_id", 0))
      refute changeset.valid?

      assert changeset.errors == [
               objective_id: {"does not exist", []}
             ]
    end
  end

  defp with_cycle_params(_) do
    now = DateTime.utc_now()
    iso8601_now = now |> DateTime.to_iso8601()

    params = %{
      "starts_at" => iso8601_now,
      "ends_at" => iso8601_now,
      "title" => "title"
    }

    {:ok, %{now: now, valid_params: params}}
  end

  defp with_objective_params(_) do
    user = Test.Factories.User.create!()
    cycle = Test.Factories.Cycle.create!(user: user)
    okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: user)

    params = %{
      "content" => "Some content",
      "okr_id" => okr.id
    }

    {:ok, %{valid_params: params, cycle: cycle, okr: okr, user: user}}
  end

  defp with_key_result_params(_) do
    {:ok, %{valid_params: objective_params}} = with_objective_params([])
    objective = Test.Factories.Objective.create!(objective_params)

    params = %{
      "content" => "KeyResult content",
      "objective_id" => objective.id
    }

    {:ok, %{valid_params: params, objective: objective}}
  end
end
