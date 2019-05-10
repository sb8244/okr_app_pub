defmodule OkrAppWeb.Api.KeyResultController do
  use OkrAppWeb, :controller

  alias OkrAppWeb.Serializer
  alias OkrApp.Objectives

  def create(conn, params) do
    with {:create, {:ok, key_result}} <- {:create, Objectives.create_key_result(params)} do
      conn
      |> put_status(201)
      |> json(%{data: Serializer.KeyResult.to_map(key_result)})
    else
      {:create, {:error, changeset}} ->
        error(conn, changeset)
    end
  end

  def update(conn, params = %{"id" => id}) do
    with {:find, {:ok, key_result}} <- {:find, Objectives.find_key_result(id)},
         {:update, {:ok, key_result}} <- {:update, Objectives.update_key_result(key_result, params)} do
      conn
      |> json(%{data: Serializer.KeyResult.to_map(key_result)})
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
