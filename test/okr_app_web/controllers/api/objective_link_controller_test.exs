defmodule OkrAppWeb.Api.ObjectiveLinkControllerTest do
  use OkrAppWeb.ConnCase, async: true

  alias OkrAppWeb.Api.ObjectiveLinkController, as: Controller

  describe "index/2" do
    setup :with_linked_objectives

    test "linked objectives can be searched for", %{conn: conn, linking: linking} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.index(%{"source_objective_id" => linking.source_objective_id, "linked_to_objective_id" => linking.linked_to_objective_id})
        |> json_response(200)
        |> ResponseSnapshot.store_and_compare!(path: "api/objective_links/index.json")

      assert json["data"] |> length() == 1
      assert json["data"] |> List.first() |> Map.get("id") == linking.id
    end

    test "deleted links are not returned", %{conn: conn, linking: linking} do
      OkrApp.Objectives.unlink_objectives(linking.id)

      assert conn
             |> put_private(:current_user, %{})
             |> Controller.index(%{})
             |> json_response(200) == %{"data" => []}
    end

    test "no matches can be returned", %{conn: conn, linking: linking} do
      assert conn
             |> put_private(:current_user, %{})
             |> Controller.index(%{"source_objective_id" => linking.source_objective_id, "linked_to_objective_id" => 0})
             |> json_response(200) == %{"data" => []}

      assert conn
             |> put_private(:current_user, %{})
             |> Controller.index(%{"source_objective_id" => 0, "linked_to_objective_id" => linking.linked_to_objective_id})
             |> json_response(200) == %{"data" => []}
    end
  end

  describe "create/2" do
    setup :with_objectives

    test "2 objectives can be linked together", %{conn: conn, objective1: objective1, objective2: objective2} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.create(%{"source_objective_id" => objective1.id, "linked_to_objective_id" => objective2.id})
        |> json_response(201)
        |> ResponseSnapshot.store_and_compare!(path: "api/objective_links/create.json")

      assert json["data"]["source_objective_id"] == objective1.id
      assert json["data"]["linked_to_objective_id"] == objective2.id
    end

    test "requests are idempotent", %{conn: conn, objective1: objective1, objective2: objective2} do
      conn = put_private(conn, :current_user, %{})

      json1 =
        Controller.create(conn, %{"source_objective_id" => objective1.id, "linked_to_objective_id" => objective2.id})
        |> json_response(201)

      json2 =
        Controller.create(conn, %{"source_objective_id" => objective1.id, "linked_to_objective_id" => objective2.id})
        |> json_response(201)

      assert json1 == json2
    end

    test "invalid requests return the error", %{conn: conn} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.create(%{"source_objective_id" => 0, "linked_to_objective_id" => 0})
        |> json_response(422)
        |> ResponseSnapshot.store_and_compare!(path: "api/objective_links/create_fail.json")

      assert json == %{"errors" => %{"source_objective_id" => ["does not exist"]}}
    end
  end

  describe "delete/2" do
    setup :with_linked_objectives

    test "2 objectives can be unlinked", %{conn: conn, linking: linking} do
      assert conn
             |> put_private(:current_user, %{})
             |> Controller.delete(%{"id" => linking.id})
             |> response(204) == ""
    end

    test "an invalid id is a failure", %{conn: conn} do
      assert conn
             |> put_private(:current_user, %{})
             |> Controller.delete(%{"id" => 0})
             |> json_response(404) == %{"error" => "not found"}
    end
  end

  def with_objectives(_) do
    user = Test.Factories.User.create!(%{active: false})
    cycle = Test.Factories.Cycle.create!(user: user)
    okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: user)
    objective = Test.Factories.Objective.create!(%{"okr_id" => okr.id})
    objective2 = Test.Factories.Objective.create!(%{"okr_id" => okr.id})

    {:ok, %{okr: okr, objective1: objective, objective2: objective2}}
  end

  def with_linked_objectives(ctx) do
    {:ok, %{okr: okr, objective1: objective1, objective2: objective2}} = with_objectives(ctx)
    {:ok, linking} = OkrApp.Objectives.link_objectives(objective1.id, objective2.id)

    {:ok, %{okr: okr, objective1: objective1, objective2: objective2, linking: linking}}
  end
end
