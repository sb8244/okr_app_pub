defmodule OkrApp.Users.GroupStoreTest do
  use OkrApp.DataCase, async: false

  alias OkrApp.Users.{GroupStore}

  describe "all/0" do
    test "no users returns an empty list" do
      assert GroupStore.all() == []
    end

    test "with users returns all groups" do
      group = Test.Factories.Group.create!(%{})
      group2 = Test.Factories.Group.create!(%{})

      assert GroupStore.all() == [group, group2]
    end

    test "search parameter searches on ILIKE name" do
      group = Test.Factories.Group.create!(%{"name" => "Test A"})
      group2 = Test.Factories.Group.create!(%{"name" => "Test B"})

      assert GroupStore.all(%{"search" => "st a"}) == [group]
      assert GroupStore.all(%{search: "st b"}) == [group2]
      assert_raise(FunctionClauseError, fn -> GroupStore.all(%{search: nil}) end)
    end

    test "id parameter searches exact" do
      group = Test.Factories.Group.create!()
      _ = Test.Factories.Group.create!()
      assert GroupStore.all(%{"id" => group.id}) == [group]
    end

    test "active=true will only include groups with active users" do
      group = Test.Factories.Group.create!()
      group2 = Test.Factories.Group.create!()

      user = Test.Factories.User.create!(%{active: true})
      user2 = Test.Factories.User.create!(%{active: false})
      {:ok, _} = OkrApp.Users.insert_user_in_group(user, group)
      {:ok, _} = OkrApp.Users.insert_user_in_group(user2, group)
      {:ok, _} = OkrApp.Users.insert_user_in_group(user2, group2)

      assert GroupStore.all(%{"active" => true}) == [group]
    end
  end
end
