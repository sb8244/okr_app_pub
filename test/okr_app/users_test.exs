defmodule OkrApp.UsersTest do
  use OkrApp.DataCase, async: true

  alias OkrApp.Users
  alias Users.{Group}

  describe "create_group/1" do
    setup :with_group_params

    test "attributes are required" do
      assert {:error, changeset} = Users.create_group(%{})
      refute changeset.valid?

      assert changeset.errors == [
               name: {"can't be blank", [validation: :required]}
             ]
    end

    test "a valid group can be created", %{valid_params: params} do
      assert {:ok, %Group{} = group} = Users.create_group(params)
      assert group.id
      assert group.name == params["name"]
    end
  end

  describe "insert_user_in_group/2" do
    test "the GroupUser is created" do
      user = Test.Factories.User.create!()
      group = Test.Factories.Group.create!()
      assert {:ok, group_user} = Users.insert_user_in_group(user, group)
      assert group_user.id
      assert group_user.group_id == group.id
      assert group_user.user_id == user.id
    end

    test "the GroupUser is not double inserted, it isn't updated at all" do
      user = Test.Factories.User.create!()
      group = Test.Factories.Group.create!()
      assert {:ok, group_user} = Users.insert_user_in_group(user, group)
      assert {:ok, group_user2} = Users.insert_user_in_group(user, group)
      assert group_user.id
      assert group_user == group_user2
    end
  end

  defp with_group_params(_) do
    params = %{
      "name" => "A group"
    }

    {:ok, %{valid_params: params}}
  end
end
