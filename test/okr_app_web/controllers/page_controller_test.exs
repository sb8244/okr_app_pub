defmodule OkrAppWeb.PageControllerTest do
  use OkrAppWeb.ConnCase, async: true
  alias OkrApp.Repo

  @session Plug.Session.init(
             store: :cookie,
             key: "_app",
             encryption_salt: "yadayada",
             signing_salt: "yadayada"
           )

  describe "index/2" do
    test "loading works when not logged in", %{conn: conn} do
      html =
        conn
        |> get("/")
        |> response(200)

      assert html =~ "react-app"
      assert Repo.aggregate(OkrApp.Analytics.AnalyticsEvent, :count, :id) == 0
    end

    test "loading works when logged in, logging the load event", %{conn: conn} do
      Test.Factories.User.create!(%{user_name: "steve@test.com"})

      html =
        conn
        |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
        |> Plug.Session.call(@session)
        |> Plug.Conn.fetch_session()
        |> put_session("samly_nameid", "steve@test.com")
        |> get("/app/gibberish")
        |> response(200)

      assert html =~ "react-app"
      assert Repo.aggregate(OkrApp.Analytics.AnalyticsEvent, :count, :id) == 1
    end
  end
end
