defmodule OkrAppWeb.Serializer.Objective do
  use Remodel

  attributes([
    :id,
    :content,
    :cancelled_at,
    :inserted_at,
    :updated_at,
    :mid_score,
    :final_score,
    :assessment,
    :key_results,
    :contributes_to_objectives,
    :contributed_by_objectives
  ])

  def assessment(%{objective_assessment: nil}), do: nil

  def assessment(%{objective_assessment: %Ecto.Association.NotLoaded{}}), do: nil

  def assessment(%{objective_assessment: assessment}) do
    assessment
    |> OkrAppWeb.Serializer.ObjectiveAssessment.to_map()
  end

  def key_results(record) do
    record.key_results
    |> Enum.map(&OkrAppWeb.Serializer.KeyResult.to_map/1)
  end

  def contributes_to_objectives(%{contributes_to_objectives: %Ecto.Association.NotLoaded{}}), do: []

  def contributes_to_objectives(record) do
    record.contributes_to_objectives
    |> Enum.map(&OkrAppWeb.Serializer.LinkedObjective.to_map/1)
  end

  def contributed_by_objectives(%{contributed_by_objectives: %Ecto.Association.NotLoaded{}}), do: []

  def contributed_by_objectives(record) do
    record.contributed_by_objectives
    |> Enum.map(&OkrAppWeb.Serializer.LinkedObjective.to_map/1)
  end

  def mid_score(record = %{__struct__: mod}) do
    mod.mid_score(record)
  end

  def final_score(record = %{__struct__: mod}) do
    mod.final_score(record)
  end
end
