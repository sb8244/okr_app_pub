defmodule OkrAppWeb.Api.Analytics.OkrViewController do
  use OkrAppWeb, :controller

  alias OkrApp.Analytics

  def show(conn, %{"owner_id" => owner_id}) do
    owner = %{id: owner_id}

    data = %{
      distinct_okr_views_30_days: Analytics.distinct_okr_views(owner: owner, days: 30),
      total_okr_views_30_days: Analytics.total_okr_views(owner: owner, days: 30)
    }

    conn
    |> json(%{data: data})
  end
end
