defmodule OkrAppWeb.Serializer.LinkedObjective do
  use Remodel

  alias OkrAppWeb.Serializer

  attributes([:id, :content, :cancelled_at, :inserted_at, :updated_at, :owner])

  def owner(%{user: user}) when not is_nil(user) do
    Serializer.PlainUser.to_map(user)
    |> Map.put("owner_type", "user")
  end

  def owner(%{group: group}) when not is_nil(group) do
    Serializer.Group.to_map(group)
    |> Map.put("owner_type", "group")
  end
end
