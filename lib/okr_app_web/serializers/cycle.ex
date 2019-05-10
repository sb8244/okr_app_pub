defmodule OkrAppWeb.Serializer.Cycle do
  use Remodel

  attributes([:id, :title, :starts_at, :ends_at, :active])

  def active(record = %{__struct__: mod}) do
    mod.active?(record)
  end
end
