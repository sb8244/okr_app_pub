defmodule OkrAppWeb.HealthController do
  use OkrAppWeb, :controller

  def show(conn, _) do
    conn
    |> send_resp(204, "")
  end
end
