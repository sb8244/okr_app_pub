defmodule OkrAppWeb.Serializer.ObjectiveAssessment do
  use Remodel

  attributes([:id, :assessment, :objective_id, :inserted_at, :updated_at])
end
