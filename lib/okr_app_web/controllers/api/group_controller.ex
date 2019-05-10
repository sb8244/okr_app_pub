defmodule OkrAppWeb.Api.GroupController do
  use OkrAppWeb, :controller

  alias OkrApp.{Users}
  alias OkrAppWeb.Serializer

  def index(conn, params) do
    data =
      Map.merge(params, %{"active" => true})
      |> Users.all_groups(order_by: [asc: :name])
      |> Enum.map(&Serializer.Group.to_map/1)

    conn
    |> json(%{data: data})
  end
end
