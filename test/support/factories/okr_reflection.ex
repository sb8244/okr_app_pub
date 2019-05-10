defmodule Test.Factories.OkrReflection do
  def create!(override_params = %{"okr_id" => _}) do
    params =
      %{
        "reflection" => "How I did"
      }
      |> Map.merge(override_params)

    {:ok, struct} = OkrApp.Objectives.create_okr_reflection(params)
    struct
  end
end
