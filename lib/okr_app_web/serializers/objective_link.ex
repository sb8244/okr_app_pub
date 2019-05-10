defmodule OkrAppWeb.Serializer.ObjectiveLink do
  use Remodel

  attributes([:id, :inserted_at, :source_objective_id, :linked_to_objective_id])
end
