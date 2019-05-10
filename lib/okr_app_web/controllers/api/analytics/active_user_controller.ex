defmodule OkrAppWeb.Api.Analytics.ActiveUserController do
  use OkrAppWeb, :controller

  alias OkrApp.Analytics

  def show(conn, _params) do
    data = %{
      users_with_active_objectives_count: Analytics.users_with_active_objectives_count(),
      total_active_user_count: Analytics.total_active_user_count(),
      unique_user_count_7_days: Analytics.unique_user_count(days: 7)
    }

    conn
    |> json(%{data: data})
  end
end
