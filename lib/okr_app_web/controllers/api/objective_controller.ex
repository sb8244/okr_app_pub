defmodule OkrAppWeb.Api.ObjectiveController do
  use OkrAppWeb, :controller

  alias OkrAppWeb.Serializer
  alias OkrApp.{Objectives, Repo}

  def create(conn, params) do
    with {:create, {:ok, objective}} <- {:create, create_objective(params)} do
      conn
      |> put_status(201)
      |> json(%{data: Serializer.Objective.to_map(objective)})
    else
      {:create, {:error, errors = %Ecto.Changeset{}}} ->
        error(conn, errors)
    end
  end

  def update(conn, params = %{"id" => id}) do
    with {:find, {:ok, objective}} <- {:find, Objectives.find_objective(id)},
         {:update, {:ok, objective}} <- {:update, Objectives.update_objective(objective, params)},
         {:preload, objective} <- {:preload, Repo.preload(objective, [:key_results])} do
      conn
      |> json(%{data: Serializer.Objective.to_map(objective)})
    else
      {:find, {:error, :not_found}} ->
        error(conn, :not_found)

      {:update, {:error, changeset}} ->
        error(conn, changeset)
    end
  end

  defp create_objective(params) do
    Repo.transaction(fn ->
      with {:create_objective, {:ok, objective}} <- {:create_objective, Objectives.create_objective(params)},
           {:create_key_results, {:ok, objective}} <- {:create_key_results, create_key_results(objective, params)} do
        objective
      else
        {_, {:error, %Ecto.Changeset{} = e}} ->
          Repo.rollback(e)
      end
    end)
  end

  defp create_key_results(objective = %{id: objective_id}, %{"key_results" => key_results}) when is_list(key_results) do
    key_results
    |> Enum.reduce([], fn kr_params, acc ->
      kr_params = Map.put(kr_params, "objective_id", objective_id)
      create_key_result(kr_params, acc)
    end)
    |> case do
      {:error, _} = e ->
        e

      created_results ->
        {:ok, Map.put(objective, :key_results, created_results)}
    end
  end

  defp create_key_results(objective, _) do
    {:ok, Map.put(objective, :key_results, [])}
  end

  defp create_key_result(params, list) when is_list(list) do
    case Objectives.create_key_result(params) do
      {:ok, key_result} ->
        list ++ [key_result]

      {:error, _} = e ->
        e
    end
  end

  defp create_key_result(_, e = {:error, _}), do: e

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
