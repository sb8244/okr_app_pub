defmodule OkrApp.Objectives.CycleStore do
  import Ecto.Query

  alias OkrApp.Repo
  alias OkrApp.Objectives.Cycle

  def all(params = %{}, opts \\ []) do
    params = Enum.map(params, fn {k, v} -> {to_string(k), v} end) |> Enum.into(%{})
    clean_params = Map.drop(params, ["active", "present_or_future"])

    OkrApp.Query.ListQuery.get_query(Cycle, clean_params, opts)
    |> append_list_query(:present_or_future, Map.has_key?(params, "present_or_future"), Map.get(params, "present_or_future"))
    |> append_list_query(:active, Map.has_key?(params, "active"), Map.get(params, "active"))
    |> Repo.all()
  end

  def create(params, user: user) do
    Cycle.changeset(params, user: user)
    |> Repo.insert()
  end

  defp append_list_query(query, _, false, _), do: query

  defp append_list_query(query, :present_or_future, true, val) when val == true or val == "true" do
    now = DateTime.utc_now()

    query
    |> where(^dynamic([c], c.ends_at >= ^now))
  end

  defp append_list_query(query, :active, true, val) when val == true or val == "true" do
    now = DateTime.utc_now()

    query
    |> where(^dynamic([c], c.starts_at <= ^now))
    |> where(^dynamic([c], c.ends_at >= ^now))
  end
end
