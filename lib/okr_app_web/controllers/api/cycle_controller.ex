defmodule OkrAppWeb.Api.CycleController do
  use OkrAppWeb, :controller

  alias OkrApp.Objectives
  alias OkrAppWeb.Serializer

  def index(conn, params) do
    data =
      Objectives.all_cycles(params, order_by: [desc: :ends_at])
      |> Enum.map(&Serializer.Cycle.to_map/1)

    conn
    |> json(%{data: data})
  end
end
