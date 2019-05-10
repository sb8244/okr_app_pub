defmodule OkrAppWeb.Api.OkrReflectionController do
  use OkrAppWeb, :controller

  alias OkrAppWeb.Serializer
  alias OkrApp.{Objectives}

  @serializer Serializer.OkrReflection
  @create_fn &Objectives.create_okr_reflection/1
  @find_fn &Objectives.find_okr_reflection/1
  @update_fn &Objectives.update_okr_reflection/2

  def create(conn, params) do
    with {:create, {:ok, struct}} <- {:create, @create_fn.(params)} do
      conn
      |> put_status(201)
      |> json(%{data: @serializer.to_map(struct)})
    else
      {:create, {:error, errors = %Ecto.Changeset{}}} ->
        error(conn, errors)
    end
  end

  def update(conn, params = %{"id" => id}) do
    with {:find, {:ok, struct}} <- {:find, @find_fn.(id)},
         {:update, {:ok, struct}} <- {:update, @update_fn.(struct, params)} do
      conn
      |> json(%{data: @serializer.to_map(struct)})
    else
      {:find, {:error, :not_found}} ->
        error(conn, :not_found)

      {:update, {:error, changeset}} ->
        error(conn, changeset)
    end
  end

  defp error(conn, :not_found) do
    conn
    |> put_status(404)
    |> json(%{error: "not found"})
  end

  defp error(conn, changeset) do
    conn
    |> put_status(422)
    |> json(Serializer.Unprocessable.to_map(changeset))
  end
end
