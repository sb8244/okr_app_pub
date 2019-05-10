defmodule OkrApp.Users.UserStore do
  alias OkrApp.Users.User
  alias OkrApp.Repo

  import Ecto.Query

  def all(), do: all(%{}, [])

  def all(params = %{}, opts \\ []) do
    params = Enum.map(params, fn {k, v} -> {to_string(k), v} end) |> Enum.into(%{})
    clean_params = Map.drop(params, ["search", "slug"])

    query =
      OkrApp.Query.ListQuery.get_query(User, clean_params, opts)
      |> append_list_query(:search, Map.has_key?(params, "search"), Map.get(params, "search"))
      |> append_list_query(:slug, Map.has_key?(params, "slug"), Map.get(params, "slug"))

    Repo.all(query)
  end

  def find(id) do
    Repo.get(User, id)
    |> single_result()
  end

  def add(user_params) do
    User.changeset(user_params, :create)
    |> Repo.insert(on_conflict: :replace_all, conflict_target: :id)
  end

  def get_user_by(user_name: user_name) do
    Repo.get_by(User, user_name: to_string(user_name))
    |> single_result()
  end

  def get_active_user(user_name: user_name) do
    query =
      from(
        u in User,
        where: u.active == true,
        where: u.user_name == ^to_string(user_name)
      )

    Repo.one(query)
    |> single_result()
  end

  defp single_result(nil_or_user) do
    case nil_or_user do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  defp append_list_query(query, _, false, _), do: query

  defp append_list_query(query, :search, true, search) when is_bitstring(search) do
    search = "%#{search}%"
    where(query, fragment("user_name ILIKE ? OR given_name ILIKE ? OR family_name ILIKE ?", ^search, ^search, ^search))
  end

  defp append_list_query(query, :slug, true, slug) when is_bitstring(slug) do
    query
    |> where(^dynamic([e], not is_nil(e.given_name) and not is_nil(e.family_name)))
    |> where(fragment("lower(given_name || '.' || family_name) = lower(?)", ^slug))
  end
end
