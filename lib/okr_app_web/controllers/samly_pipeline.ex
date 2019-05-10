defmodule OkrAppWeb.SamlyPipeline do
  use Plug.Builder
  import Mockery.Macro

  alias OkrApp.{Users}

  plug(:ensure_user_exists)

  def ensure_user_exists(conn = %{private: %{samly_assertion: samly_assertion}}, _opts) do
    with {:user_name, user_name} <- {:user_name, samly_assertion |> Map.get(:subject) |> Map.get(:name)},
         {:get_user, {:ok, _user}} <- {:get_user, mockable(Users).get_active_user(user_name: user_name)} do
      conn
    else
      {:get_user, {:error, :user_not_found}} ->
        conn
        |> send_resp(401, "You do not have an account setup. Please contact helpdesk@salesloft.com to be setup.")
        |> halt()
    end
  end
end
