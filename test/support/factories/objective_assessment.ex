defmodule Test.Factories.ObjectiveAssessment do
  def create!(override_params = %{"objective_id" => _}) do
    params =
      %{
        "assessment" => "How I did"
      }
      |> Map.merge(override_params)

    {:ok, assessment} = OkrApp.Objectives.create_objective_assessment(params)
    assessment
  end
end
