defmodule OkrAppWeb.Plug.UserAuth do
  import Plug.Conn
  require Logger

  def init([]), do: []

  def call(conn, _opts) do
    with user_name when is_bitstring(user_name) and user_name != "" <- get_session(conn, "samly_nameid"),
         {:ok, user} <- OkrApp.Users.get_active_user(user_name: user_name) do
      conn
      |> put_private(:current_user, user)
    else
      err ->
        Logger.error("#{__MODULE__} error=unauthorized url=#{request_url(conn)} err=#{inspect(err)}")

        conn
        |> put_status(401)
        |> Phoenix.Controller.json(%{error: "Not signed in"})
        |> halt()
    end
  end
end
