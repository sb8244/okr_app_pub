"test/support/factories"
|> Path.join("*.ex")
|> Path.wildcard()
|> Enum.map(&Code.require_file/1)

# Add some Users
users =
  [user1, user2, inactive_user] = [
    %OkrApp.Users.User{
      active: true,
      department: "engineering",
      emails: [
        %{
          "primary" => true,
          "type" => "work",
          "value" => "steve.bussey+dev@salesloft.com"
        }
      ],
      family_name: "Bussey",
      given_name: "Stephen",
      id: "00ufwa6fexO0ZuIMu0h7",
      inserted_at: ~N[2018-08-14 03:18:23.189684],
      manager_display_name: "Brian",
      manager_id: "1",
      middle_name: nil,
      roles: [],
      updated_at: ~N[2018-08-14 03:18:23.194708],
      user_name: "steve.bussey+dev@salesloft.com"
    },
    %OkrApp.Users.User{
      active: true,
      department: nil,
      emails: [
        %{
          "primary" => true,
          "type" => "work",
          "value" => "steve.bussey+brian@salesloft.com"
        }
      ],
      family_name: "Culler",
      given_name: "Brian",
      id: "00ufx168coHNRAjtq0h7",
      inserted_at: ~N[2018-08-14 03:18:23.189676],
      manager_display_name: nil,
      manager_id: nil,
      middle_name: nil,
      roles: [],
      updated_at: ~N[2018-08-14 03:18:23.194607],
      user_name: "steve.bussey+brian@salesloft.com"
    },
    %OkrApp.Users.User{
      active: false,
      department: nil,
      emails: [
        %{
          "primary" => true,
          "type" => "work",
          "value" => "steve.bussey+disabled@salesloft.com"
        }
      ],
      family_name: "Inactive",
      given_name: "I'm",
      id: "FAKE_ID",
      inserted_at: ~N[2018-08-14 03:18:23.189676],
      manager_display_name: nil,
      manager_id: nil,
      middle_name: nil,
      roles: [],
      updated_at: ~N[2018-08-14 03:18:23.194607],
      user_name: "steve.bussey+disabled@salesloft.com"
    }
  ]

Enum.each(users, &OkrApp.Repo.insert!/1)

# Add some groups

group1 = Test.Factories.Group.create!(%{"name" => "Little Five Endpoints"})
group2 = Test.Factories.Group.create!(%{"name" => "Company", "pinned" => true})
inactive_group = Test.Factories.Group.create!(%{"name" => "Disabled"})

{:ok, _} = OkrApp.Users.insert_user_in_group(user1, group1)
{:ok, _} = OkrApp.Users.insert_user_in_group(user2, group2)
{:ok, _} = OkrApp.Users.insert_user_in_group(user1, group2)
{:ok, _} = OkrApp.Users.insert_user_in_group(inactive_user, inactive_group)

# Add some cycle/okrs

# Avoid timex for as long as possible
now = NaiveDateTime.utc_now()
beginning_of_month = Timex.beginning_of_month(now)
end_of_month = Timex.end_of_month(now)

cycle1 = Test.Factories.Cycle.create!(%{"starts_at" => beginning_of_month, "ends_at" => beginning_of_month, "title" => "Q1"}, user: user1)
cycle2 = Test.Factories.Cycle.create!(%{"starts_at" => beginning_of_month, "ends_at" => end_of_month, "title" => "Q2"}, user: user2)
_cycle3 = Test.Factories.Cycle.create!(%{"starts_at" => beginning_of_month, "ends_at" => end_of_month, "title" => "Q2 - No OKR"}, user: user2)
okr1 = Test.Factories.Okr.create!(%{"cycle_id" => cycle1.id}, owner: user1)
okr2 = Test.Factories.Okr.create!(%{"cycle_id" => cycle2.id}, owner: user1)
okr3 = Test.Factories.Okr.create!(%{"cycle_id" => cycle1.id}, owner: user2)
okr4 = Test.Factories.Okr.create!(%{"cycle_id" => cycle2.id}, owner: inactive_user)
group_okr = Test.Factories.Okr.create!(%{"cycle_id" => cycle2.id}, owner: group1)

defmodule OkrSeed do
  def add_objective_and_kr_to_okr(okr) do
    objective = Test.Factories.Objective.create!(%{"okr_id" => okr.id, "content" => "Support the rollout of OKRs across the company"})

    kr1 =
      Test.Factories.KeyResult.create!(%{
        "objective_id" => objective.id,
        "mid_score" => "0.1",
        "final_score" => "0.55",
        "content" => "Deploy OKR app by halfway through the qtr"
      })

    kr2 =
      Test.Factories.KeyResult.create!(%{
        "objective_id" => objective.id,
        "content" => "Follow up with leadership about most effective messaging for OKR creation and sharing"
      })

    kr3 =
      Test.Factories.KeyResult.create!(%{
        "objective_id" => objective.id,
        "mid_score" => "0.4",
        "final_score" => "0.8",
        "content" => "Create notification system for company of what their pending OKRs are"
      })

    kr4 =
      Test.Factories.KeyResult.create!(%{
        "objective_id" => objective.id,
        "cancelled_at" => DateTime.utc_now(),
        "content" => "Create analytics system into how OKRs are used"
      })

    {objective, [kr1, kr2, kr3, kr4]}
  end
end

OkrSeed.add_objective_and_kr_to_okr(okr1)
OkrSeed.add_objective_and_kr_to_okr(okr1)
OkrSeed.add_objective_and_kr_to_okr(okr1)

OkrSeed.add_objective_and_kr_to_okr(okr2)
OkrSeed.add_objective_and_kr_to_okr(okr2)

OkrSeed.add_objective_and_kr_to_okr(okr3)

OkrSeed.add_objective_and_kr_to_okr(okr4)

OkrSeed.add_objective_and_kr_to_okr(group_okr)
