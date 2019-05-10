defmodule OkrApp.Objectives.OkrStoreTest do
  use OkrApp.DataCase, async: true

  alias OkrApp.Objectives.OkrStore
  alias OkrApp.Users.{Group, User}

  describe "create/2" do
    setup :with_okr_params

    test "attributes are required" do
      assert {:error, changeset} = OkrStore.create(%{}, owner: %User{id: "x"})
      refute changeset.valid?

      assert changeset.errors == [
               cycle_id: {"can't be blank", [validation: :required]}
             ]
    end

    test "a validate Okr can be created", %{valid_params: params, cycle: cycle, user: user} do
      assert {:ok, okr} = OkrStore.create(params, owner: user)
      assert okr.id
      assert okr.user_id == user.id
      assert okr.group_id == nil
      assert okr.cycle_id == cycle.id
    end

    test "a group can own an Okr", %{valid_params: params, cycle: cycle} do
      group = Test.Factories.Group.create!()
      assert {:ok, okr} = OkrStore.create(params, owner: group)
      assert okr.id
      assert okr.user_id == nil
      assert okr.group_id == group.id
      assert okr.cycle_id == cycle.id
    end

    test "an invalid user cannot be provided", %{valid_params: params} do
      assert {:error, changeset} = OkrStore.create(params, owner: %User{id: "x"})
      refute changeset.valid?

      assert changeset.errors == [
               user_id: {"does not exist", []}
             ]
    end

    test "an invalid group cannot be provided", %{valid_params: params} do
      assert {:error, changeset} = OkrStore.create(params, owner: %Group{id: 0})
      refute changeset.valid?

      assert changeset.errors == [
               group_id: {"does not exist", []}
             ]
    end
  end

  describe "all/2" do
    test "all okrs are returned" do
      user = Test.Factories.User.create!(%{active: true})
      cycle1 = Test.Factories.Cycle.create!(%{"ends_at" => "2018-07-01T00:00:00"}, user: user)
      cycle2 = Test.Factories.Cycle.create!(%{"ends_at" => "2018-08-01T00:00:00"}, user: user)
      okr1 = Test.Factories.Okr.create!(%{"cycle_id" => cycle1.id}, owner: user)
      okr2 = Test.Factories.Okr.create!(%{"cycle_id" => cycle2.id}, owner: user)

      assert OkrStore.all(%{}) == [okr1, okr2]
    end

    test "user_id filter can be applied" do
      user = Test.Factories.User.create!(%{active: true})
      user2 = Test.Factories.User.create!(%{active: true})
      cycle1 = Test.Factories.Cycle.create!(%{"ends_at" => "2018-07-01T00:00:00"}, user: user)
      cycle2 = Test.Factories.Cycle.create!(%{"ends_at" => "2018-08-01T00:00:00"}, user: user)
      okr1 = Test.Factories.Okr.create!(%{"cycle_id" => cycle1.id}, owner: user)
      okr2 = Test.Factories.Okr.create!(%{"cycle_id" => cycle2.id}, owner: user2)

      assert OkrStore.all(%{"user_id" => user.id}) == [okr1]
      assert OkrStore.all(%{user_id: user2.id}) == [okr2]
    end
  end

  defp with_okr_params(_) do
    user = Test.Factories.User.create!()
    cycle = Test.Factories.Cycle.create!(user: user)

    params = %{"cycle_id" => cycle.id}

    {:ok, %{valid_params: params, cycle: cycle, user: user}}
  end
end
