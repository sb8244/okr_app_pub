defmodule OkrAppWeb.Serializer.KeyResult do
  use Remodel

  attributes([:id, :content, :mid_score, :final_score, :cancelled_at, :inserted_at, :updated_at])

  def final_score(record), do: OkrApp.Objectives.round_score(record.final_score, :key_result)
  def mid_score(record), do: OkrApp.Objectives.round_score(record.mid_score, :key_result)
end
