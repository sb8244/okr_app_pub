defmodule OkrAppWeb.Api.Analytics.ActiveUserControllerTest do
  use OkrAppWeb.ConnCase, async: true

  alias OkrAppWeb.Api.Analytics.ActiveUserController, as: Controller

  describe "show/2" do
    test "the endpoint returns data", %{conn: conn} do
      assert conn
             |> put_private(:current_user, {})
             |> Controller.show(%{})
             |> json_response(200) == %{
               "data" => %{
                 "users_with_active_objectives_count" => 0,
                 "total_active_user_count" => 0,
                 "unique_user_count_7_days" => 0
               }
             }
    end
  end
end
