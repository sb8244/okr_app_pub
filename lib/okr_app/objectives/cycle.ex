defmodule OkrApp.Objectives.Cycle do
  @moduledoc """
  Cycles are time periods that Objectives are executed in.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias OkrApp.Users.User

  schema "cycles" do
    field(:title, :string, null: false)
    field(:starts_at, :utc_datetime, null: false)
    field(:ends_at, :utc_datetime, null: false)

    belongs_to(:user, User, type: :string)
    has_many(:okrs, OkrApp.Objectives.Okr)

    timestamps()
  end

  def changeset(params, user: %User{id: user_id}) do
    params = Map.put(params, "user_id", user_id)

    %__MODULE__{}
    |> cast(params, [:title, :starts_at, :ends_at, :user_id])
    |> validate_required([:title, :starts_at, :ends_at, :user_id])
    |> foreign_key_constraint(:user_id)
  end

  def active?(%{starts_at: starts_at, ends_at: ends_at}) do
    now = DateTime.utc_now()
    DateTime.compare(now, starts_at) == :gt && DateTime.compare(now, ends_at) == :lt
  end
end
