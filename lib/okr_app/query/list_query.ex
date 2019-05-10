defmodule OkrApp.Query.ListQuery do
  import Ecto.Query

  def get_query(schema, params, opts) do
    limit = Keyword.get(opts, :limit)
    page = Keyword.get(opts, :page, 1)
    ordering = Keyword.get(opts, :order_by)

    from(e in schema)
    |> apply_dynamic_and_params(params)
    |> apply_limit(limit)
    |> apply_paging(page: page, limit: limit)
    |> apply_ordering(ordering)
  end

  defp apply_dynamic_and_params(query, params) do
    dynamic = Enum.reduce(params, true, &add_dynamic_and/2)
    where(query, ^dynamic)
  end

  defp add_dynamic_and({field, value}, dynamic) when is_list(value) do
    dynamic([e], ^dynamic and field(e, ^atomize(field)) in ^value)
  end

  defp add_dynamic_and({field, value}, dynamic) when is_nil(value) do
    dynamic([e], ^dynamic and is_nil(field(e, ^atomize(field))))
  end

  defp add_dynamic_and({field, value}, dynamic) do
    dynamic([e], ^dynamic and field(e, ^atomize(field)) == ^value)
  end

  defp atomize(v) when is_bitstring(v), do: String.to_atom(v)

  defp atomize(v) when is_atom(v), do: v

  defp apply_limit(query, limit) do
    case limit do
      nil -> query
      limit -> query |> limit(^limit)
    end
  end

  defp apply_paging(query, page: page, limit: limit) do
    case limit do
      nil ->
        query

      limit ->
        query |> offset(^((page - 1) * limit))
    end
  end

  defp apply_ordering(query, ordering) do
    case ordering do
      nil ->
        query

      ordering ->
        query |> order_by(^ordering)
    end
  end
end
