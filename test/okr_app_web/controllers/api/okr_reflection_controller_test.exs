defmodule OkrAppWeb.Api.OkrReflectionControllerTest do
  use OkrAppWeb.ConnCase, async: true
  import OkrApp.CommonSetup

  alias OkrAppWeb.Api.OkrReflectionController, as: Controller

  describe "create/2" do
    setup :with_okr

    test "a valid reflection can be created under an okr", %{conn: conn, okr: okr} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.create(%{"reflection" => "test", "okr_id" => okr.id})
        |> json_response(201)
        |> ResponseSnapshot.store_and_compare!(path: "api/okr_reflections/create.json")

      assert %{"data" => %{"reflection" => "test", "id" => id}} = json
      assert is_integer(id)
    end

    test "an invalid reflection can not be created", %{conn: conn} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.create(%{})
        |> json_response(422)
        |> ResponseSnapshot.store_and_compare!(path: "api/okr_reflections/create_invalid.json")

      assert json == %{
               "errors" => %{
                 "reflection" => ["can't be blank"],
                 "okr_id" => ["can't be blank"]
               }
             }
    end
  end

  describe "update/2" do
    setup :with_okr_reflection

    test "a valid reflection can be updated", %{conn: conn, okr_reflection: %{id: id}} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.update(%{"reflection" => "updated", "id" => id})
        |> json_response(200)
        |> ResponseSnapshot.store_and_compare!(path: "api/okr_reflections/update.json")

      assert %{"data" => %{"reflection" => "updated", "id" => ^id}} = json
    end

    test "an reflection has required data", %{conn: conn, okr_reflection: %{id: id}} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.update(%{"id" => id, "reflection" => ""})
        |> json_response(422)
        |> ResponseSnapshot.store_and_compare!(path: "api/okr_reflections/update_invalid.json")

      assert json == %{
               "errors" => %{
                 "reflection" => ["can't be blank"]
               }
             }
    end

    test "an invalid reflection is a 404", %{conn: conn} do
      assert conn
             |> put_private(:current_user, %{})
             |> Controller.update(%{"reflection" => "updated", "id" => 0})
             |> json_response(404) == %{"error" => "not found"}
    end
  end
end
