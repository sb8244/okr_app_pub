defmodule OkrAppWeb.Api.OkrControllerTest do
  use OkrAppWeb.ConnCase, async: true

  alias OkrAppWeb.Api.OkrController, as: Controller

  describe "index/2" do
    test "all okr for a user is returned, with newest cycle (ends_at) first", %{conn: conn} do
      user = Test.Factories.User.create!()
      cycle1 = Test.Factories.Cycle.create!(%{"ends_at" => "2018-07-01T00:00:00"}, user: user)
      cycle2 = Test.Factories.Cycle.create!(%{"ends_at" => "2018-08-01T00:00:00"}, user: user)
      okr1 = Test.Factories.Okr.create!(%{"cycle_id" => cycle1.id}, owner: user)
      okr2 = Test.Factories.Okr.create!(%{"cycle_id" => cycle2.id}, owner: user)
      objective1_1 = Test.Factories.Objective.create!(%{"okr_id" => okr1.id})
      objective1_2 = Test.Factories.Objective.create!(%{"okr_id" => okr1.id})
      objective2_1 = Test.Factories.Objective.create!(%{"okr_id" => okr2.id})
      kr1_1_1 = Test.Factories.KeyResult.create!(%{"objective_id" => objective1_1.id})
      kr1_1_2 = Test.Factories.KeyResult.create!(%{"objective_id" => objective1_1.id})
      kr1_2_1 = Test.Factories.KeyResult.create!(%{"objective_id" => objective1_2.id})
      kr2_1_1 = Test.Factories.KeyResult.create!(%{"objective_id" => objective2_1.id})
      {:ok, _linking} = OkrApp.Objectives.link_objectives(objective1_1.id, objective2_1.id)

      json =
        conn
        |> put_private(:current_user, user)
        |> Controller.index(%{"user_id" => user.id})
        |> json_response(200)
        |> ResponseSnapshot.store_and_compare!(path: "api/user/okrs/index.json")

      assert length(json["data"]) == 2

      first_okr = Enum.at(json["data"], 0)
      second_okr = Enum.at(json["data"], 1)

      assert get_in(first_okr, ["cycle", "id"]) == cycle2.id
      assert get_in(second_okr, ["cycle", "id"]) == cycle1.id

      assert first_okr |> get_in(["objectives"]) |> Enum.map(& &1["id"]) == [objective2_1.id]
      assert second_okr |> get_in(["objectives"]) |> Enum.map(& &1["id"]) == [objective1_1.id, objective1_2.id]

      assert first_okr |> get_in(["objectives"]) |> Enum.at(0) |> Map.get("key_results") |> Enum.map(& &1["id"]) == [kr2_1_1.id]
      assert second_okr |> get_in(["objectives"]) |> Enum.at(0) |> Map.get("key_results") |> Enum.map(& &1["id"]) == [kr1_1_1.id, kr1_1_2.id]
      assert second_okr |> get_in(["objectives"]) |> Enum.at(1) |> Map.get("key_results") |> Enum.map(& &1["id"]) == [kr1_2_1.id]

      assert OkrApp.Repo.aggregate(OkrApp.Analytics.AnalyticsEvent, :count, :id) == 1
    end

    test "deleted Objectives and KeyResults are not returned", %{conn: conn} do
      user = Test.Factories.User.create!(%{active: false})
      cycle1 = Test.Factories.Cycle.create!(user: user)
      okr1 = Test.Factories.Okr.create!(%{"cycle_id" => cycle1.id}, owner: user)
      deleted_objective = Test.Factories.Objective.create!(%{"okr_id" => okr1.id})
      objective = Test.Factories.Objective.create!(%{"okr_id" => okr1.id})

      deleted_key_result = Test.Factories.KeyResult.create!(%{"objective_id" => objective.id})
      key_result = Test.Factories.KeyResult.create!(%{"objective_id" => objective.id})
      Test.Factories.KeyResult.create!(%{"objective_id" => deleted_objective.id})

      {:ok, _} = OkrApp.Objectives.delete_objective(deleted_objective)
      {:ok, _} = OkrApp.Objectives.delete_key_result(deleted_key_result)

      json =
        conn
        |> put_private(:current_user, user)
        |> Controller.index(%{"user_id" => user.id})
        |> json_response(200)

      assert length(json["data"]) == 1

      first_okr = Enum.at(json["data"], 0)
      assert first_okr |> get_in(["objectives"]) |> Enum.map(& &1["id"]) == [objective.id]
      assert first_okr |> get_in(["objectives"]) |> Enum.flat_map(& &1["key_results"]) |> Enum.map(& &1["id"]) == [key_result.id]
    end

    test "group owned Okrs can be queried", %{conn: conn} do
      group = Test.Factories.Group.create!()
      user = Test.Factories.User.create!()
      cycle = Test.Factories.Cycle.create!(user: user)
      okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: group)

      json =
        conn
        |> put_private(:current_user, user)
        |> Controller.index(%{"group_id" => group.id})
        |> json_response(200)
        |> ResponseSnapshot.store_and_compare!(path: "api/user/okrs/index_group.json")

      assert length(json["data"]) == 1
      assert json["data"] |> Enum.at(0) |> Map.get("id") == okr.id
    end
  end

  describe "create/2" do
    setup :with_cycle_user_group

    test "a user OKR can be created", %{conn: conn, user: user, cycle: cycle} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.create(%{"cycle_id" => cycle.id, "user_id" => user.id})
        |> json_response(201)
        |> ResponseSnapshot.store_and_compare!(path: "api/user/okrs/create.json")

      cycle_id = cycle.id
      user_id = user.id
      assert %{"data" => %{"cycle" => %{"id" => ^cycle_id}, "id" => id}} = json
      assert %{user_id: ^user_id, group_id: nil} = OkrApp.Repo.get!(OkrApp.Objectives.Okr, id)
    end

    test "a group OKR can be created", %{conn: conn, group: group, cycle: cycle} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.create(%{"cycle_id" => cycle.id, "group_id" => group.id})
        |> json_response(201)

      cycle_id = cycle.id
      group_id = group.id
      assert %{"data" => %{"cycle" => %{"id" => ^cycle_id}, "id" => id}} = json
      assert %{group_id: ^group_id, user_id: nil} = OkrApp.Repo.get!(OkrApp.Objectives.Okr, id)
    end

    test "an invalid cycle id is an error", %{conn: conn, group: group} do
      json =
        conn
        |> put_private(:current_user, %{})
        |> Controller.create(%{"cycle_id" => 0, "group_id" => group.id})
        |> json_response(422)

      assert json == %{"data" => %{"errors" => %{"cycle_id" => ["does not exist"]}}}
    end

    test "an invalid user/group id is an error", %{conn: conn, cycle: cycle} do
      assert conn
             |> put_private(:current_user, %{})
             |> Controller.create(%{"cycle_id" => cycle.id, "user_id" => "0"})
             |> json_response(422) == %{"data" => %{"errors" => %{"user" => ["does not exist"]}}}

      assert conn
             |> put_private(:current_user, %{})
             |> Controller.create(%{"cycle_id" => cycle.id, "group_id" => "0"})
             |> json_response(422) == %{"data" => %{"errors" => %{"group" => ["does not exist"]}}}
    end
  end

  defp with_cycle_user_group(_) do
    group = Test.Factories.Group.create!()
    user = Test.Factories.User.create!()
    cycle = Test.Factories.Cycle.create!(user: user)

    {:ok, %{user: user, cycle: cycle, group: group}}
  end
end
