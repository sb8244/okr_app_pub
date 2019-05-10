defmodule OkrAppWeb.Serializer.User do
  defmodule NestedGroup do
    use Remodel

    attributes([:id, :name])
  end

  use Remodel

  attributes([:id, :user_name, :active, :name, :emails, :groups, :slug])

  def name(record) do
    [record.given_name, record.family_name]
    |> Enum.join(" ")
    |> String.trim()
  end

  def groups(record) do
    case record.groups do
      groups when is_list(groups) ->
        NestedGroup.to_map(groups)
    end
  end

  def slug(record = %{__struct__: mod}) do
    mod.slug(record)
  end
end
