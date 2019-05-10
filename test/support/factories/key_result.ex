defmodule Test.Factories.KeyResult do
  def create!(override_params = %{"objective_id" => _}) do
    params =
      %{
        "content" => "KeyResult Content",
        "mid_score" => Decimal.new(0),
        "final_score" => Decimal.new(0),
      }
      |> Map.merge(override_params)

    {:ok, obj} = OkrApp.Objectives.create_key_result(params)
    obj
  end
end
