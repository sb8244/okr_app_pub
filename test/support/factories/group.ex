defmodule Test.Factories.Group do
  def create!(), do: create!(%{})

  def create!(override_params) do
    params =
      %{
        "name" => "A group",
        "pinned" => false
      }
      |> Map.merge(override_params)

    {:ok, group} = OkrApp.Users.create_group(params)
    group
  end
end
