defmodule OkrApp.Analytics.AnalyticsEvent do
  use Ecto.Schema
  import Ecto.Changeset

  alias OkrApp.Users.{User}

  schema "analytics_events" do
    field(:type, :string, null: false)
    field(:metadata, :map, null: false)

    belongs_to(:user, User, type: :string)

    timestamps()
  end

  def changeset(params = %{}, user: %{id: user_id}) do
    params = Map.put(params, "user_id", user_id)

    %__MODULE__{}
    |> cast(params, [:type, :metadata, :user_id])
    |> validate_required([:type, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
