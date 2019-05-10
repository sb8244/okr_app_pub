defmodule OkrAppWeb.Api.CycleControllerTest do
  use OkrAppWeb.ConnCase, async: true

  alias OkrAppWeb.Api.CycleController, as: Controller

  describe "index/2" do
    test "all cycles are returned, sorted by end_at DESC", %{conn: conn} do
      user = Test.Factories.User.create!()
      cycle1 = Test.Factories.Cycle.create!(%{"ends_at" => Timex.shift(Timex.now(), minutes: 5)}, user: user)
      cycle2 = Test.Factories.Cycle.create!(%{"ends_at" => Timex.shift(Timex.now(), minutes: 10)}, user: user)

      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.index(%{"user_id" => user.id})
        |> json_response(200)
        |> ResponseSnapshot.store_and_compare!(path: "api/cycles/index.json")

      assert length(json["data"]) == 2
      assert json["data"] |> Enum.map(& &1["id"]) == [cycle2.id, cycle1.id]
    end

    test "present_or_future=true", %{conn: conn} do
      user = Test.Factories.User.create!()
      _ = Test.Factories.Cycle.create!(%{"ends_at" => Timex.shift(Timex.now(), minutes: -5)}, user: user)
      cycle2 = Test.Factories.Cycle.create!(%{"ends_at" => Timex.shift(Timex.now(), minutes: 10)}, user: user)

      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.index(%{"user_id" => user.id, "present_or_future" => "true"})
        |> json_response(200)

      assert json["data"] |> Enum.map(& &1["id"]) == [cycle2.id]
    end
  end
end
