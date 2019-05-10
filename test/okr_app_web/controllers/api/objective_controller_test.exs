defmodule OkrAppWeb.Api.ObjectiveControllerTest do
  use OkrAppWeb.ConnCase, async: true

  alias OkrAppWeb.Api.ObjectiveController, as: Controller

  describe "create/2" do
    setup :with_okr

    test "a valid objective can be made with no key_results", %{conn: conn, okr: okr} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.create(%{"content" => "test", "okr_id" => okr.id})
        |> json_response(201)
        |> ResponseSnapshot.store_and_compare!(path: "api/objectives/create.json")

      assert %{"data" => %{"id" => id, "key_results" => [], "content" => "test"}} = json
      assert {:ok, _} = OkrApp.Objectives.find_objective(id)
    end

    test "an objective can be made with multiple key_results", %{conn: conn, okr: okr} do
      params = %{"content" => "test", "okr_id" => okr.id, "key_results" => [%{"content" => "a"}, %{"content" => "b"}]}

      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.create(params)
        |> json_response(201)
        |> ResponseSnapshot.store_and_compare!(path: "api/objectives/create_with_key_results.json")

      assert %{"data" => %{"id" => id, "key_results" => [%{"content" => "a"}, %{"content" => "b"}], "content" => "test"}} = json
      assert {:ok, objective} = OkrApp.Objectives.find_objective(id)
      objective = OkrApp.Repo.preload(objective, :key_results)
      assert length(objective.key_results) == 2
    end

    test "a failing key_result returns an error without committing partially", %{conn: conn, okr: okr} do
      params = %{"content" => "test", "okr_id" => okr.id, "key_results" => [%{"content" => "a"}, %{"content" => ""}]}

      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.create(params)
        |> json_response(422)

      assert json == %{"errors" => %{"content" => ["can't be blank"]}}
      assert OkrApp.Repo.one(OkrApp.Objectives.Objective) == nil
      assert OkrApp.Repo.one(OkrApp.Objectives.KeyResult) == nil
    end
  end

  describe "update/2" do
    setup :with_objective

    test "an objective is updated", %{conn: conn, objective: objective} do
      now = DateTime.utc_now()
      now_s = DateTime.to_iso8601(now)

      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.update(%{"id" => to_string(objective.id), "content" => "test", "cancelled_at" => now_s, "deleted_at" => now_s})
        |> json_response(200)
        |> ResponseSnapshot.store_and_compare!(path: "api/objectives/update.json")

      assert json["data"]["content"] == "test"
      assert json["data"]["cancelled_at"] == now_s

      objective = OkrApp.Repo.get!(OkrApp.Objectives.Objective, objective.id)
      assert objective.deleted_at == now
      assert objective.cancelled_at == now
    end

    test "invalid params are a 422", %{conn: conn, objective: objective} do
      assert conn
             |> put_private(:current_user, %{})
             |> Controller.update(%{"id" => to_string(objective.id), "content" => ""})
             |> json_response(422) == %{"errors" => %{"content" => ["can't be blank"]}}
    end
  end

  def with_okr(_) do
    user = Test.Factories.User.create!(%{active: false})
    cycle = Test.Factories.Cycle.create!(user: user)
    okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: user)

    {:ok, %{okr: okr}}
  end

  def with_objective(_) do
    user = Test.Factories.User.create!(%{active: false})
    cycle = Test.Factories.Cycle.create!(user: user)
    okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: user)
    objective = Test.Factories.Objective.create!(%{"okr_id" => okr.id})

    {:ok, %{okr: okr, objective: objective}}
  end
end
