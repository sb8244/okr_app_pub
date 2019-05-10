defmodule OkrAppWeb.Api.KeyResultControllerTest do
  use OkrAppWeb.ConnCase, async: true

  alias OkrAppWeb.Api.KeyResultController, as: Controller

  describe "create/2" do
    setup :with_key_results

    test "a valid KR can be created under an objective", %{conn: conn, objective: objective} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.create(%{"content" => "test", "objective_id" => objective.id})
        |> json_response(201)
        |> ResponseSnapshot.store_and_compare!(path: "api/key_results/create.json")

      assert %{"data" => %{"content" => "test", "id" => id}} = json
      assert is_integer(id)
    end

    test "a valid objective_id is required", %{conn: conn} do
      assert conn
             |> put_private(:current_user, %{})
             |> Controller.create(%{"content" => "test", "objective_id" => 0})
             |> json_response(422) == %{"errors" => %{"objective_id" => ["does not exist"]}}
    end
  end

  describe "update/2" do
    setup :with_key_results

    test "a key result is updated", %{conn: conn, key_result: key_result} do
      now_s = DateTime.to_iso8601(DateTime.utc_now())

      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.update(%{"id" => to_string(key_result.id), "mid_score" => "0.1", "final_score" => "0.5", "content" => "test", "cancelled_at" => now_s})
        |> json_response(200)
        |> ResponseSnapshot.store_and_compare!(path: "api/key_results/update.json")

      assert json["data"]["content"] == "test"
      assert json["data"]["mid_score"] == "0.1"
      assert json["data"]["final_score"] == "0.5"
      assert json["data"]["cancelled_at"] == now_s
    end

    test "invalid params are a 422", %{conn: conn, key_result: key_result} do
      assert conn
             |> put_private(:current_user, %{})
             |> Controller.update(%{"id" => to_string(key_result.id), "content" => ""})
             |> json_response(422) == %{"errors" => %{"content" => ["can't be blank"]}}
    end

    test "the mid_score and final_score cannot go below 0 or above 1", %{conn: conn, key_result: key_result} do
      ["mid_score", "final_score"]
      |> Enum.each(fn field ->
        assert conn
               |> put_private(:current_user, %{})
               |> Controller.update(%{"id" => to_string(key_result.id), field => "-0.000000001"})
               |> json_response(422) == %{"errors" => %{field => ["must be 0.0 -> 1.0"]}}

        assert conn
               |> put_private(:current_user, %{})
               |> Controller.update(%{"id" => to_string(key_result.id), field => "1.000000001"})
               |> json_response(422) == %{"errors" => %{field => ["must be 0.0 -> 1.0"]}}

        assert conn
               |> put_private(:current_user, %{})
               |> Controller.update(%{"id" => to_string(key_result.id), field => "1"})
               |> json_response(200)

        assert conn
               |> put_private(:current_user, %{})
               |> Controller.update(%{"id" => to_string(key_result.id), field => "0"})
               |> json_response(200)

        assert conn
               |> put_private(:current_user, %{})
               |> Controller.update(%{"id" => to_string(key_result.id), field => 0.005})
               |> json_response(200)
      end)
    end
  end

  def with_key_results(_) do
    user = Test.Factories.User.create!(%{active: false})
    cycle = Test.Factories.Cycle.create!(user: user)
    okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: user)
    objective = Test.Factories.Objective.create!(%{"okr_id" => okr.id})
    key_result = Test.Factories.KeyResult.create!(%{"objective_id" => objective.id})

    {:ok, %{key_result: key_result, objective: objective}}
  end
end
