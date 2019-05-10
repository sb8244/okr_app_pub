defmodule OkrAppWeb.Api.ObjectiveAssessmentControllerTest do
  use OkrAppWeb.ConnCase, async: true
  import OkrApp.CommonSetup

  alias OkrAppWeb.Api.ObjectiveAssessmentController, as: Controller

  describe "create/2" do
    setup :with_objectives

    test "a valid assessment can be created under an objective", %{conn: conn, objective1: objective} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.create(%{"assessment" => "test", "objective_id" => objective.id})
        |> json_response(201)
        |> ResponseSnapshot.store_and_compare!(path: "api/objective_assessments/create.json")

      assert %{"data" => %{"assessment" => "test", "id" => id}} = json
      assert is_integer(id)
    end

    test "an invalid assessment can not be created", %{conn: conn} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.create(%{})
        |> json_response(422)
        |> ResponseSnapshot.store_and_compare!(path: "api/objective_assessments/create_invalid.json")

      assert json == %{
               "errors" => %{
                 "assessment" => ["can't be blank"],
                 "objective_id" => ["can't be blank"]
               }
             }
    end
  end

  describe "update/2" do
    setup :with_objective_assessment

    test "a valid assessment can be updated", %{conn: conn, assessment: %{id: id}} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.update(%{"assessment" => "updated", "id" => id})
        |> json_response(200)
        |> ResponseSnapshot.store_and_compare!(path: "api/objective_assessments/update.json")

      assert %{"data" => %{"assessment" => "updated", "id" => ^id}} = json
    end

    test "an assessment has required data", %{conn: conn, assessment: %{id: id}} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.update(%{"id" => id, "assessment" => ""})
        |> json_response(422)
        |> ResponseSnapshot.store_and_compare!(path: "api/objective_assessments/update_invalid.json")

      assert json == %{
               "errors" => %{
                 "assessment" => ["can't be blank"]
               }
             }
    end

    test "an invalid assessment is a 404", %{conn: conn} do
      assert conn
             |> put_private(:current_user, %{})
             |> Controller.update(%{"assessment" => "updated", "id" => 0})
             |> json_response(404) == %{"error" => "not found"}
    end
  end
end
