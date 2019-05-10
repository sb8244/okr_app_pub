defmodule OkrApp.Store.SimpleEctoStore do
  alias OkrApp.Repo

  @methods [:all, :find, :create, :update, :delete]

  defmacro __using__(opts) do
    schema = Keyword.fetch!(opts, :schema)
    only = Keyword.get(opts, :only, @methods) |> Enum.map(& {&1, true}) |> Enum.into(%{})

    quote do
      @schema unquote(schema)

      if unquote(only[:all]) do
        def all(params = %{}, opts \\ []) do
          params = Enum.map(params, fn {k, v} -> {to_string(k), v} end) |> Enum.into(%{})

          OkrApp.Query.ListQuery.get_query(@schema, params, opts)
          |> Repo.all()
        end
      end

      if unquote(only[:find]) do
        def find(id) when is_bitstring(id) or is_integer(id) do
          Repo.get(@schema, id)
          |> case do
            nil -> {:error, :not_found}
            res -> {:ok, res}
          end
        end
      end

      if unquote(only[:create]) do
        def create(params) do
          @schema.create_changeset(params)
          |> Repo.insert()
        end
      end

      if unquote(only[:update]) do
        def update(struct = %@schema{}, params) do
          @schema.update_changeset(struct, params)
          |> Repo.update()
        end
      end

      if unquote(only[:delete]) do
        def delete(struct = %@schema{}) do
          Ecto.Changeset.change(struct, deleted_at: DateTime.utc_now())
          |> Repo.update()
        end
      end
    end
  end
end
