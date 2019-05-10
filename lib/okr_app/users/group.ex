defmodule OkrApp.Users.Group do
  @moduledoc """
  Groups are collections of users for organizational and display purposes. A group
  can have Okr objects as well.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias OkrApp.Users.{GroupUser, User}

  schema "groups" do
    field(:name, :string, null: false)
    field(:slug, :string, null: false)
    field(:pinned, :boolean, null: false)

    many_to_many(:users, User, join_through: GroupUser)

    timestamps()
  end

  def changeset(params) do
    changeset =
      %__MODULE__{}
      |> cast(params, [:name, :pinned])
      |> validate_required([:name])

    case changeset.changes do
      %{name: name} ->
        slug = generate_slug(name)
        put_change(changeset, :slug, slug)

      _ ->
        changeset
    end
  end

  def generate_slug(name) do
    name
    |> String.downcase()
    |> String.replace(~r/\W/, "-")
  end
end
