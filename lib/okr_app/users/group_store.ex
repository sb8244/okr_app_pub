defmodule OkrApp.Users.GroupStore do
  alias OkrApp.Users.{Group}
  alias OkrApp.Repo

  import Ecto.Query

  def all(), do: all(%{}, [])

  def all(params = %{}, opts \\ []) do
    params = Enum.map(params, fn {k, v} -> {to_string(k), v} end) |> Enum.into(%{})
    clean_params = Map.drop(params, ["search", "active"])

    query =
      OkrApp.Query.ListQuery.get_query(Group, clean_params, opts)
      |> append_list_query(:search, Map.has_key?(params, "search"), Map.get(params, "search"))
      |> append_list_query(:active, Map.has_key?(params, "active"), Map.get(params, "active"))

    Repo.all(query)
  end

  def find(id) do
    Repo.get(Group, id)
    |> case do
      nil -> {:error, :not_found}
      group -> {:ok, group}
    end
  end

  defp append_list_query(query, _, false, _), do: query

  defp append_list_query(query, :search, true, search) when is_bitstring(search) do
    search = "%#{search}%"
    where(query, fragment("name ILIKE ?", ^search))
  end

  defp append_list_query(query, :active, true, true) do
    query
    |> join(:inner, [group], u in assoc(group, :users), u.active == true)
    |> distinct([q], true)
  end
end
