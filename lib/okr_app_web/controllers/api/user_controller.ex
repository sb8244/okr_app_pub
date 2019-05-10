defmodule OkrAppWeb.Api.UserController do
  use OkrAppWeb, :controller

  alias OkrApp.Users
  alias OkrAppWeb.Serializer

  def me(conn = %{private: %{current_user: user}}, _params) do
    user = Users.preload_users(user, :groups)

    conn
    |> json(%{data: Serializer.User.to_map(user)})
  end

  def index(conn, params) do
    data =
      Users.all(params, order_by: [asc: :family_name])
      |> Users.preload_users(:groups)
      |> Enum.map(&Serializer.User.to_map/1)

    conn
    |> json(%{data: data})
  end
end
