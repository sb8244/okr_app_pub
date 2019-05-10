defmodule OkrAppWeb.Serializer.UserTest do
  use ExUnit.Case, async: true

  alias OkrAppWeb.Serializer
  alias OkrApp.Users.{Group, User}

  def get_user(params) do
    params =
      %{
        groups: []
      }
      |> Map.merge(params)

    struct(User, params)
  end

  test "the right attributes are returned" do
    assert Serializer.User.to_map(get_user(%{}))
           |> Map.keys() == [:active, :emails, :groups, :id, :name, :slug, :user_name]
  end

  describe "name" do
    test "given_name family_name is returned" do
      assert %{name: "Test Tester"} = Serializer.User.to_map(get_user(%{given_name: "Test", family_name: "Tester"}))
    end

    test "just given_name is returned" do
      assert %{name: "Test"} = Serializer.User.to_map(get_user(%{given_name: "Test", family_name: ""}))
    end

    test "just family_name is returned" do
      assert %{name: "Tester"} = Serializer.User.to_map(get_user(%{given_name: nil, family_name: "Tester"}))
    end
  end

  describe "groups" do
    test "no groups is empty" do
      assert %{groups: groups} = Serializer.User.to_map(get_user(%{}))
      assert groups == []
    end

    test "groups are encoded" do
      assert %{groups: groups} = Serializer.User.to_map(get_user(%{groups: [%Group{id: 1, name: "1"}, %Group{id: 2, name: "2"}]}))

      assert groups == [
               %{id: 1, name: "1"},
               %{id: 2, name: "2"}
             ]
    end

    test "unloaded groups is an error" do
      assert_raise(CaseClauseError, fn ->
        Serializer.User.to_map(%User{})
      end)
    end
  end
end
