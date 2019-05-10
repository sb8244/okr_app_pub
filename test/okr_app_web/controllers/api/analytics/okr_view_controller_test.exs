defmodule OkrAppWeb.Api.Analytics.OkrViewControllerTest do
  use OkrAppWeb.ConnCase, async: true

  alias OkrAppWeb.Api.Analytics.OkrViewController, as: Controller

  describe "show/2" do
    test "stats are queried and shown", %{conn: conn} do
      assert conn
             |> put_private(:current_user, {})
             |> Controller.show(%{"owner_id" => "x"})
             |> json_response(200) == %{
               "data" => %{
                 "distinct_okr_views_30_days" => 0,
                 "total_okr_views_30_days" => 0
               }
             }
    end
  end
end
