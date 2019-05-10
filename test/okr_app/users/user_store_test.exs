defmodule OkrApp.Users.UserStoreTest do
  use OkrApp.DataCase, async: false

  alias OkrApp.Users.UserStore
  alias OkrApp.Users.User

  describe "add/1" do
    test "an invalid user returns an error" do
      errors = [
        id: {"can't be blank", [validation: :required]},
        user_name: {"can't be blank", [validation: :required]},
        active: {"can't be blank", [validation: :required]}
      ]

      {:error, %Ecto.Changeset{errors: ^errors, valid?: false}} = UserStore.add(%{})
    end

    test "a valid user is created", %{test: test} do
      params = %{
        id: to_string(test),
        user_name: "test",
        active: true,
        family_name: "a",
        given_name: "b",
        middle_name: "c",
        emails: [%{x: 1}],
        roles: ["admin"],
        manager_id: "e",
        manager_display_name: "f",
        department: "g"
      }

      {:ok, user} = UserStore.add(params)

      Enum.each(params, fn {k, v} ->
        assert Map.fetch!(user, k) == v
      end)
    end

    test "a duplicate user updates the existing row", %{test: test} do
      id = to_string(test)

      {:ok, user1 = %User{id: ^id}} =
        %{id: id, user_name: "test", active: true}
        |> UserStore.add()

      {:ok, user2 = %User{id: ^id}} =
        %{id: id, user_name: "updated", active: true}
        |> UserStore.add()

      assert user1.user_name == "test"
      assert user2.user_name == "updated"
      assert UserStore.find(id) == {:ok, user2}
    end

    test "a duplicate user that doesn't have the field updates it to nil", %{test: test} do
      id = to_string(test)

      {:ok, user1 = %User{id: ^id}} =
        %{id: id, user_name: "test", active: true, roles: ["test"]}
        |> UserStore.add()

      {:ok, user2 = %User{id: ^id}} =
        %{id: id, user_name: "test", active: true}
        |> UserStore.add()

      assert user1.roles == ["test"]
      assert user2.roles == []
    end
  end

  describe "all/0" do
    test "no users returns an empty list" do
      assert UserStore.all() == []
    end

    test "with users returns all users", %{test: test} do
      id = to_string(test)
      id2 = id <> "2"

      {:ok, user1 = %User{id: ^id}} =
        %{id: id, user_name: "test", active: true}
        |> UserStore.add()

      {:ok, user2 = %User{id: ^id2}} =
        %{id: id2, user_name: "test", active: true}
        |> UserStore.add()

      assert UserStore.all() == [user1, user2]
    end

    test "search parameter searches on ILIKE user_name, given_name, family_name" do
      {:ok, _} = UserStore.add(%{id: "id", user_name: "a word", active: true})
      {:ok, user2} = UserStore.add(%{id: "id2", user_name: "will Match", active: true})
      {:ok, user3} = UserStore.add(%{id: "id3", user_name: "x", active: true, given_name: "will match"})
      {:ok, user4} = UserStore.add(%{id: "id4", user_name: "x", active: true, family_name: "WILL MATCH"})

      assert UserStore.all(%{"search" => "lL ma"}) |> Enum.sort() == [user2, user3, user4] |> Enum.sort()
      assert UserStore.all(%{search: "lL ma"}) |> Enum.sort() == [user2, user3, user4] |> Enum.sort()
      assert_raise(FunctionClauseError, fn -> UserStore.all(%{search: nil}) end)
    end

    test "slug parameter searches on given_name.family_name" do
      {:ok, _} = UserStore.add(%{id: "id", user_name: "x", active: true, given_name: "x", family_name: "y"})
      {:ok, user} = UserStore.add(%{id: "match", user_name: "x", active: true, given_name: "Steve", family_name: "Tester"})

      assert UserStore.all(%{slug: "steve.tester"}) == [user]
    end

    test "slug parameter needs the full name to search" do
      {:ok, _} = UserStore.add(%{id: "1", user_name: "x", active: true, given_name: "Steve"})
      {:ok, _} = UserStore.add(%{id: "2", user_name: "x", active: true, given_name: "Steve", family_name: ""})

      assert UserStore.all(%{slug: "steve"}) == []
      assert UserStore.all(%{slug: "steve."}) == []
      assert UserStore.all(%{slug: "steve. "}) == []
      assert_raise(FunctionClauseError, fn -> UserStore.all(%{slug: nil}) end)
    end

    test "id parameter searches exact" do
      {:ok, user} = UserStore.add(%{id: "id", user_name: "a word", active: true})
      {:ok, _} = UserStore.add(%{id: "id2", user_name: "will Match", active: true})
      assert UserStore.all(%{"id" => "id"}) == [user]
    end

    test "multiple filters are AND together" do
      {:ok, user} = UserStore.add(%{id: "id", user_name: "a word", active: true})
      {:ok, _} = UserStore.add(%{id: "id2", user_name: "will Match", active: true})
      assert UserStore.all(%{id: "id", user_name: "a word"}) == [user]
      assert UserStore.all(%{id: "id", user_name: "will Match"}) == []
    end
  end

  describe "find/1" do
    test "no user is an error" do
      assert UserStore.find("nope") == {:error, :user_not_found}
    end

    test "a user can be returned", %{test: test} do
      id = to_string(test)

      {:ok, user} =
        %{id: id, user_name: "test", active: true}
        |> UserStore.add()

      assert UserStore.find(id) == {:ok, user}
    end
  end

  describe "get_user_by/1" do
    test "no user is an error" do
      assert UserStore.get_user_by(user_name: "nope") == {:error, :user_not_found}
    end

    test "a user can be returned regardless of active", %{test: test} do
      {:ok, user} =
        %{id: to_string(test), user_name: "test", active: false}
        |> UserStore.add()

      assert UserStore.get_user_by(user_name: "test") == {:ok, user}
    end
  end

  describe "get_active_user/1" do
    test "no user is an error" do
      assert UserStore.get_active_user(user_name: "nope") == {:error, :user_not_found}
    end

    test "a user can be returned", %{test: test} do
      {:ok, user} =
        %{id: to_string(test), user_name: "test", active: true}
        |> UserStore.add()

      assert UserStore.get_active_user(user_name: "test") == {:ok, user}
    end

    test "an inactive user is an error", %{test: test} do
      {:ok, _} =
        %{id: to_string(test), user_name: "test", active: false}
        |> UserStore.add()

      assert UserStore.get_active_user(user_name: "test") == {:error, :user_not_found}
    end
  end
end
