defmodule Test.Factories.User do
  def create!(), do: create!(%{})

  def create!(override_params) do
    id = UUID.uuid4()

    params =
      %{
        id: id,
        user_name: id,
        active: true
      }
      |> Map.merge(override_params)

    {:ok, user} = OkrApp.Users.UserStore.add(params)
    user
  end
end
