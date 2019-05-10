defmodule OkrAppWeb.PageController do
  use OkrAppWeb, :controller

  def index(conn, _params) do
    logged_in_email = get_session(conn, "samly_nameid")
    track_view(logged_in_email)

    render(conn, "index.html")
  end

  defp track_view(nil) do
    nil
  end

  defp track_view(email) when is_bitstring(email) do
    {:ok, _} = OkrApp.Analytics.create_analytics_event!(:user_load, user_name: email)
  end
end
