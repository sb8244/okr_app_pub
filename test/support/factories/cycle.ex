defmodule Test.Factories.Cycle do
  def create!(user: user), do: create!(%{}, user: user)

  def create!(override_params, user: user) do
    now = DateTime.utc_now()
    iso8601_now = now |> DateTime.to_iso8601()

    params =
      %{
        "starts_at" => iso8601_now,
        "ends_at" => iso8601_now,
        "title" => "Q1"
      }
      |> Map.merge(override_params)

    {:ok, cycle} = OkrApp.Objectives.create_cycle(params, user: user)
    cycle
  end
end
