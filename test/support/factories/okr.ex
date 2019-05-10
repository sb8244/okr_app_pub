defmodule Test.Factories.Okr do
  def create!(override_params = %{"cycle_id" => _}, owner: owner) do
    params = override_params

    {:ok, okr} = OkrApp.Objectives.create_okr(params, owner: owner)
    okr
  end
end
