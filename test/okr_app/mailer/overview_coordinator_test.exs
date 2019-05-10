defmodule OkrApp.Mailer.OverviewCoordinatorTest do
  use OkrApp.DataCase, async: true

  alias OkrApp.Mailer.{OverviewCoordinator, OverviewState, Recipient}

  describe "load_mailer_states/0" do
    test "no active users returns no states" do
      inactive_user = Test.Factories.User.create!(%{active: false})
      _cycle = Test.Factories.Cycle.create!(user: inactive_user)

      assert OverviewCoordinator.load_mailer_states() == []
    end

    test "no cycles returns no states" do
      Test.Factories.User.create!()
      Test.Factories.User.create!(%{active: false})

      assert OverviewCoordinator.load_mailer_states() == []
    end

    test "1 active user with 1 cycle but no okrs has no loaded objectives" do
      user = Test.Factories.User.create!(user_params())
      cycle = Test.Factories.Cycle.create!(active_cycle_params(), user: user)

      assert OverviewCoordinator.load_mailer_states() == [
               %OverviewState{cycle_title: cycle.title, loaded_objectives: [], recipient: %Recipient{to: "test@test.com", first_name: "test", slug: "test.tester"}}
             ]
    end

    test "1 active user without an email will not return a state" do
      user = Test.Factories.User.create!()
      _cycle = Test.Factories.Cycle.create!(active_cycle_params(), user: user)

      assert OverviewCoordinator.load_mailer_states() == []
    end

    test "1 active user with 1 cycle with active objectives returns the data" do
      user = Test.Factories.User.create!(user_params())
      cycle = %{title: cycle_title} = Test.Factories.Cycle.create!(active_cycle_params(), user: user)
      okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: user)
      objective = Test.Factories.Objective.create!(%{"okr_id" => okr.id})
      key_result = Test.Factories.KeyResult.create!(%{"objective_id" => objective.id})

      assert [
               %OverviewState{cycle_title: ^cycle_title, loaded_objectives: [loaded_objective | []]}
               | []
             ] = OverviewCoordinator.load_mailer_states()

      assert loaded_objective.id == objective.id
      assert loaded_objective.key_results == [key_result]
    end

    test "1 active user with 1 cycle with okr but no objectives returns the an empty state" do
      user = Test.Factories.User.create!(user_params())
      cycle = %{title: cycle_title} = Test.Factories.Cycle.create!(active_cycle_params(), user: user)
      _okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: user)

      assert [
               %OverviewState{cycle_title: ^cycle_title, loaded_objectives: []}
               | []
             ] = OverviewCoordinator.load_mailer_states()
    end

    test "1 active user with 2 cycles, but only 1 active returns the data for the active one only" do
      user = Test.Factories.User.create!(user_params())
      cycle = %{title: cycle_title} = Test.Factories.Cycle.create!(active_cycle_params(), user: user)
      _cycle2 = Test.Factories.Cycle.create!(active_cycle_params(), user: user)
      okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: user)
      objective = Test.Factories.Objective.create!(%{"okr_id" => okr.id})
      key_result = Test.Factories.KeyResult.create!(%{"objective_id" => objective.id})

      assert [
               %OverviewState{cycle_title: ^cycle_title, loaded_objectives: [loaded_objective | []]}
               | []
             ] = OverviewCoordinator.load_mailer_states()

      assert loaded_objective.id == objective.id
      assert loaded_objective.key_results == [key_result]
    end

    test "1 active user with 2 cycles, but no active objectives returns 2 empty states" do
      user = Test.Factories.User.create!(user_params())
      cycle = %{title: cycle_title} = Test.Factories.Cycle.create!(active_cycle_params(), user: user)
      _cycle2 = %{title: cycle_2_title} = Test.Factories.Cycle.create!(active_cycle_params(), user: user)
      _okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: user)

      assert [
               %OverviewState{cycle_title: ^cycle_2_title, loaded_objectives: []}
               | [
                   %OverviewState{cycle_title: ^cycle_title, loaded_objectives: []} | []
                 ]
             ] = OverviewCoordinator.load_mailer_states()
    end

    test "2 active user with 2 differing cycles, with active objectives, returns proper states" do
      user = Test.Factories.User.create!(user_params())
      user2 = Test.Factories.User.create!(user2_params())
      cycle = %{title: cycle_title} = Test.Factories.Cycle.create!(active_cycle_params(), user: user)
      cycle2 = %{title: cycle_2_title} = Test.Factories.Cycle.create!(active_cycle_params(), user: user)
      okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle.id}, owner: user)
      objective = Test.Factories.Objective.create!(%{"okr_id" => okr.id})
      key_result = Test.Factories.KeyResult.create!(%{"objective_id" => objective.id})

      okr_user2 = Test.Factories.Okr.create!(%{"cycle_id" => cycle2.id}, owner: user2)
      objective_user2 = Test.Factories.Objective.create!(%{"okr_id" => okr_user2.id})
      key_result_user2 = Test.Factories.KeyResult.create!(%{"objective_id" => objective_user2.id})

      assert states = OverviewCoordinator.load_mailer_states()
      assert length(states) == 2

      assert %OverviewState{recipient: recipient, cycle_title: ^cycle_2_title, loaded_objectives: [obj | []]} = Enum.at(states, 0)
      assert obj.id == objective_user2.id
      assert obj.key_results == [key_result_user2]
      assert recipient == %Recipient{
        to: "other@test.com",
        first_name: "OKR Ninja (no name available)",
        slug: ".tester"
      }

      assert %OverviewState{recipient: recipient, cycle_title: ^cycle_title, loaded_objectives: [obj | []]} = Enum.at(states, 1)
      assert obj.id == objective.id
      assert obj.key_results == [key_result]
      assert recipient == %Recipient{
        to: "test@test.com",
        first_name: "test",
        slug: "test.tester"
      }
    end
  end

  defp active_cycle_params() do
    %{
      "starts_at" => Timex.now() |> Timex.shift(minutes: -5),
      "ends_at" => Timex.now() |> Timex.shift(minutes: 5),
      "title" => Timex.now() |> to_string()
    }
  end

  defp user_params() do
    %{
      emails: [
        %{type: "work", value: "test@test.com", primary: true},
        %{type: "other", value: "nope@test.com", primary: false},
      ],
      given_name: "test",
      family_name: "tester"
    }
  end

  defp user2_params() do
    %{
      emails: [
        %{type: "nonsense", value: "other@test.com", primary: false},
      ],
      given_name: nil,
      family_name: "tester"
    }
  end
end
