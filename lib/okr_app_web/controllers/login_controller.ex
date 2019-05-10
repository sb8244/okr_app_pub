defmodule OkrAppWeb.LoginController do
  use OkrAppWeb, :controller

  def login(conn, _) do
    conn
    |> delete_session("samly_nameid")
    |> redirect(to: "/sso/auth/signin/okta")
  end

  def logout(conn, _) do
    conn
    |> delete_session("samly_nameid")
    |> redirect(to: "/")
  end

  if Mix.env() == :dev do
    def force_login(conn, %{"user_name" => user_name}) do
      conn
      |> put_session("samly_nameid", user_name)
      |> redirect(to: "/")
    end
  end
end
