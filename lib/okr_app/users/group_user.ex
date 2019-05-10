defmodule OkrApp.Users.GroupUser do
  @moduledoc """
  Many-many join table for Group-User
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias OkrApp.Users.{Group, User}

  schema "groups_users" do
    belongs_to(:group, Group)
    belongs_to(:user, User, type: :string)

    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:group_id, :user_id])
    |> validate_required([:group_id, :user_id])
    |> foreign_key_constraint(:group_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:group_id, name: :groups_users_group_id_user_id_index)
  end
end
