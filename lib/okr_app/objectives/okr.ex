defmodule OkrApp.Objectives.Okr do
  @moduledoc """
  An Okr is the collection of objectives in a cycle. It is owned by either a user
  or a group.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias OkrApp.Users.{Group, User}
  alias OkrApp.Objectives.{Cycle, Objective, OkrReflection}

  schema "okrs" do
    belongs_to(:user, User, type: :string)
    belongs_to(:group, Group)
    belongs_to(:cycle, Cycle)

    has_many(:objectives, Objective)
    has_one(:okr_reflection, OkrReflection)

    timestamps()
  end

  def create_changeset(params, owner: owner = %{id: owner_id}) do
    params = Map.drop(params, ["user_id", "group_id"])

    params =
      case owner do
        %User{} -> Map.put(params, "user_id", owner_id)
        %Group{} -> Map.put(params, "group_id", owner_id)
      end

    %__MODULE__{}
    |> cast(params, [:cycle_id, :group_id, :user_id])
    |> validate_required([:cycle_id])
    |> foreign_key_constraint(:cycle_id)
    |> foreign_key_constraint(:group_id)
    |> foreign_key_constraint(:user_id)
  end
end
