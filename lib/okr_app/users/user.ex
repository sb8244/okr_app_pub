defmodule OkrApp.Users.User do
  @moduledoc """
  Users are provided from Okta SCIM API. Of note, the id is a string and the
  manager_id is the email address of the user's manager.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias OkrApp.Users.{Group, GroupUser}

  @primary_key {:id, :string, autogenerate: false}
  @foreign_key_type :string
  schema "users" do
    field(:user_name, :string, null: false)
    field(:active, :boolean, null: false)

    field(:family_name, :string)
    field(:given_name, :string)
    field(:middle_name, :string)
    field(:emails, {:array, :map}, default: [])
    field(:roles, {:array, :string}, default: [])
    field(:manager_id, :string)
    field(:manager_display_name, :string)
    field(:department, :string)

    many_to_many(:groups, Group, join_through: GroupUser)

    timestamps()
  end

  def slug(%{given_name: given, family_name: family}) do
    "#{given}.#{family}"
    |> String.downcase()
  end

  def get_sendable_email(%{emails: emails}) do
    emails = List.wrap(emails)
    primary_email =
      Enum.filter(emails, fn email ->
        Map.get(email, "primary", false)
      end)
      |> List.first()

    first_email = List.first(emails)

    (primary_email || first_email || %{})
    |> Map.get("value")
    |> case do
      nil -> {:error, :no_email}
      val -> {:ok, val}
    end
  end

  def changeset(params, :create) do
    changeset(params, :update)
    |> cast(params, [:id])
    |> validate_required([:id])
    |> unique_constraint(:id, name: :users_pkey)
  end

  def changeset(params, :update) do
    %__MODULE__{}
    |> cast(params, [:user_name, :active, :family_name, :given_name, :middle_name, :emails, :roles, :manager_id, :manager_display_name, :department])
    |> validate_required([:user_name, :active])
  end
end
