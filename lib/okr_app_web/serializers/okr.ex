defmodule OkrAppWeb.Serializer.Okr do
  use Remodel

  alias OkrAppWeb.Serializer

  attributes([:id, :cycle, :objectives, :owner, :okr_reflection])

  def cycle(record) do
    Serializer.Cycle.to_map(record.cycle)
  end

  def objectives(record) do
    record.objectives
    |> Enum.map(&Serializer.Objective.to_map/1)
  end

  def okr_reflection(%{okr_reflection: nil}), do: nil

  def okr_reflection(%{okr_reflection: reflection}) do
    Serializer.OkrReflection.to_map(reflection)
  end

  def owner(%{user: user}) when not is_nil(user) do
    Serializer.PlainUser.to_map(user)
    |> Map.put("owner_type", "user")
  end

  def owner(%{group: group}) when not is_nil(group) do
    Serializer.Group.to_map(group)
    |> Map.put("owner_type", "group")
  end
end
