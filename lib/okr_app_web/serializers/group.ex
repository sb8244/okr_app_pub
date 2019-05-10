defmodule OkrAppWeb.Serializer.Group do
  use Remodel

  attributes([:id, :name, :slug, :pinned])
end
