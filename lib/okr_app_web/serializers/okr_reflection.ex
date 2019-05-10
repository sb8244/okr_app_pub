defmodule OkrAppWeb.Serializer.OkrReflection do
  use Remodel

  attributes([:id, :reflection, :okr_id, :inserted_at, :updated_at])
end
