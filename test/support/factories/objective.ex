defmodule Test.Factories.Objective do
  def create!(override_params = %{"okr_id" => _}) do
    params =
      %{
        "content" => "Objective Content"
      }
      |> Map.merge(override_params)

    {:ok, obj} = OkrApp.Objectives.create_objective(params)
    obj
  end
end
