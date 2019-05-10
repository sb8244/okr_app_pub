defmodule OkrAppWeb.Api.ObjectiveAssessmentController do
  use OkrAppWeb, :controller

  alias OkrAppWeb.Serializer
  alias OkrApp.{Objectives}

  def create(conn, params) do
    with {:create, {:ok, assessment}} <- {:create, Objectives.create_objective_assessment(params)} do
      conn
      |> put_status(201)
      |> json(%{data: Serializer.ObjectiveAssessment.to_map(assessment)})
    else
      {:create, {:error, errors = %Ecto.Changeset{}}} ->
        error(conn, errors)
    end
  end

  def update(conn, params = %{"id" => id}) do
    with {:find, {:ok, assessment}} <- {:find, Objectives.find_objective_assessment(id)},
         {:update, {:ok, assessment}} <- {:update, Objectives.update_objective_assessment(assessment, params)} do
      conn
      |> json(%{data: Serializer.ObjectiveAssessment.to_map(assessment)})
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
