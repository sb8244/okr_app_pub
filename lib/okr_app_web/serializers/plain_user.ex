defmodule OkrAppWeb.Serializer.PlainUser do
  use Remodel

  attributes([:id, :user_name, :active, :name, :emails, :slug])

  def name(record) do
    [record.given_name, record.family_name]
    |> Enum.join(" ")
    |> String.trim()
  end

  def slug(record = %{__struct__: mod}) do
    mod.slug(record)
  end
end
