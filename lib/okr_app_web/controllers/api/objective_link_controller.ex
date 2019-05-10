defmodule OkrAppWeb.Api.ObjectiveLinkController do
  use OkrAppWeb, :controller

  alias OkrAppWeb.Serializer
  alias OkrApp.{Objectives}

  def index(conn, params) do
    params = Map.put(params, "deleted_at", nil)

    data =
      Objectives.all_objective_links(params, limit: 100)
      |> Enum.map(&Serializer.ObjectiveLink.to_map/1)

    conn
    |> json(%{data: data})
  end

  def create(conn, %{"source_objective_id" => source_id, "linked_to_objective_id" => linked_id}) do
    case Objectives.link_objectives(source_id, linked_id) do
      {:ok, link} ->
        conn
        |> put_status(201)
        |> json(%{data: Serializer.ObjectiveLink.to_map(link)})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(422)
        |> json(Serializer.Unprocessable.to_map(changeset))
    end
  end

  def delete(conn, %{"id" => linking_id}) do
    case Objectives.unlink_objectives(linking_id) do
      {:ok, _link} ->
        conn
        |> put_status(204)
        |> text("")

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> json(%{error: "not found"})
    end
  end
end
