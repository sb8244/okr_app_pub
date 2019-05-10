defmodule OkrAppWeb.Api.UserControllerTest do
  use OkrAppWeb.ConnCase, async: true

  alias OkrAppWeb.Api.UserController, as: Controller

  describe "me/2" do
    test "the current user is returned with groups", %{conn: conn} do
      group = Test.Factories.Group.create!()
      user = Test.Factories.User.create!(%{active: true, given_name: "Steve", family_name: "Tester", user_name: "SteveTester"})
      {:ok, _} = OkrApp.Users.insert_user_in_group(user, group)

      json =
        conn
        |> put_private(:current_user, user)
        |> Controller.me(%{})
        |> json_response(200)
        |> ResponseSnapshot.store_and_compare!(path: "api/user/me_valid.json")

      assert json == %{
               "data" => %{
                 "id" => user.id,
                 "active" => true,
                 "emails" => [],
                 "name" => "Steve Tester",
                 "user_name" => "SteveTester",
                 "groups" => [
                   %{"id" => group.id, "name" => group.name}
                 ],
                 "slug" => "steve.tester"
               }
             }
    end
  end

  describe "index/2" do
    test "all users are returned", %{conn: conn} do
      user = Test.Factories.User.create!(%{active: true, given_name: "Steve", family_name: "Tester", user_name: "SteveTester"})
      Test.Factories.User.create!(%{active: false, given_name: "Sally", family_name: "Issatester", user_name: "SallyWillTest"})

      group = Test.Factories.Group.create!()
      {:ok, _} = OkrApp.Users.insert_user_in_group(user, group)

      json =
        conn
        |> put_private(:current_user, user)
        |> Controller.index(%{})
        |> json_response(200)
        |> ResponseSnapshot.store_and_compare!(path: "api/user/index.json")

      assert length(json["data"]) == 2
    end

    test "a search filter can be provided", %{conn: conn} do
      user = Test.Factories.User.create!(%{active: true, given_name: "Steve", family_name: "Tester", user_name: "SteveTester"})
      Test.Factories.User.create!(%{active: false, given_name: "Sally", family_name: "Issatester", user_name: "SallyWillTest"})

      json =
        conn
        |> put_private(:current_user, user)
        |> Controller.index(%{"search" => "TEv"})
        |> json_response(200)

      json2 =
        conn
        |> put_private(:current_user, user)
        |> Controller.index(%{"active" => true})
        |> json_response(200)

      assert json == json2
      assert length(json["data"]) == 1
      assert json["data"] |> List.first() |> Map.get("id") == user.id
    end

    test "a slug filter can be provided", %{conn: conn} do
      user = Test.Factories.User.create!(%{active: true, given_name: "Steve", family_name: "Tester", user_name: "SteveTester"})
      Test.Factories.User.create!(%{active: false, given_name: "Sally", family_name: "Issatester", user_name: "SallyWillTest"})

      json =
        conn
        |> put_private(:current_user, user)
        |> Controller.index(%{"slug" => "steve.tester"})
        |> json_response(200)

      assert length(json["data"]) == 1
      assert json["data"] |> List.first() |> Map.get("id") == user.id
    end
  end
end
