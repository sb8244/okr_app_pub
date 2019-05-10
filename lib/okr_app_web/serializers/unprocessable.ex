defmodule OkrAppWeb.Serializer.Unprocessable do
  def to_map(%Ecto.Changeset{errors: errors}) do
    errors =
      errors
      |> Enum.map(fn {key, error_tuple} ->
        error_list = Tuple.to_list(error_tuple)
        {key, Enum.drop(error_list, -1)}
      end)
      |> Enum.into(%{})

    %{errors: errors}
  end

  def to_map(field, error) do
    %{errors: %{field => [error]}}
  end
end
