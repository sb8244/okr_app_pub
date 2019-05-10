defmodule OkrAppWeb.EmailView do
  use OkrAppWeb, :view

  alias OkrApp.Objectives

  def mid_key_result_score(%{mid_score: score}) do
    Objectives.round_score(score, :key_result)
  end

  def final_key_result_score(%{final_score: score}) do
    Objectives.round_score(score, :key_result)
  end

  def mid_objective_score(record = %{__struct__: mod}) do
    mod.mid_score(record)
    |> Objectives.round_score(:objective)
  end

  def final_objective_score(record = %{__struct__: mod}) do
    mod.final_score(record)
    |> Objectives.round_score(:objective)
  end
end
