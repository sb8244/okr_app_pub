defmodule OkrAppWeb.Api.GroupControllerTest do
  use OkrAppWeb.ConnCase, async: true

  alias OkrAppWeb.Api.GroupController, as: Controller

  describe "index/2" do
    test "all active groups (having users) are returned", %{conn: conn} do
      group = Test.Factories.Group.create!(%{"name" => "group 1"})
      group2 = Test.Factories.Group.create!(%{"name" => "group 2"})

      user = Test.Factories.User.create!(%{active: true})
      user2 = Test.Factories.User.create!(%{active: true})
      {:ok, _} = OkrApp.Users.insert_user_in_group(user, group)
      {:ok, _} = OkrApp.Users.insert_user_in_group(user, group2)
      {:ok, _} = OkrApp.Users.insert_user_in_group(user2, group2)

      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.index(%{})
        |> json_response(200)
        |> ResponseSnapshot.store_and_compare!(path: "api/groups/index.json")

      assert length(json["data"]) == 2
    end

    test "a search filter can be provided", %{conn: conn} do
      group = Test.Factories.Group.create!(%{"name" => "group match 1"})
      group2 = Test.Factories.Group.create!(%{"name" => "group 2"})

      user = Test.Factories.User.create!(%{active: true})
      {:ok, _} = OkrApp.Users.insert_user_in_group(user, group)
      {:ok, _} = OkrApp.Users.insert_user_in_group(user, group2)

      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.index(%{"search" => "p Mat"})
        |> json_response(200)

      assert length(json["data"]) == 1
      assert json["data"] |> List.first() |> Map.get("id") == group.id
    end
  end
end
