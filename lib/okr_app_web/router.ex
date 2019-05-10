defmodule OkrAppWeb.Router do
  use OkrAppWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(OkrAppWeb.Plug.UserAuth)
  end

  pipeline :scim do
    plug(BasicAuth, use_config: {:okr_app, :scim_auth})
  end

  scope "/", OkrAppWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/health", HealthController, :show)
    get("/login", LoginController, :login)
    get("/logout", LoginController, :logout)

    if Mix.env() == :dev do
      get("/force_login", LoginController, :force_login)
    end
  end

  scope "/sso" do
    forward("/", Samly.Router)
  end

  scope "/scim/v2" do
    pipe_through(:scim)

    forward("/", Scim.Web.Plug, behavior: OkrApp.UsersScim)
  end

  # defined this way to allow go-to definition support
  alias OkrAppWeb.Api

  scope "/api" do
    pipe_through(:api)

    get("/user", Api.UserController, :me)

    resources("/cycles", Api.CycleController, only: [:index])
    resources("/key_results", Api.KeyResultController, only: [:create, :update])
    resources("/objectives", Api.ObjectiveController, only: [:create, :update])
    resources("/objective_assessments", Api.ObjectiveAssessmentController, only: [:create, :update])
    resources("/okr_reflections", Api.OkrReflectionController, only: [:create, :update])
    resources("/objective_links", Api.ObjectiveLinkController, only: [:index, :create, :delete])
    resources("/okrs", Api.OkrController, only: [:create])

    scope "/analytics" do
      get("/active_user", Api.Analytics.ActiveUserController, :show)
      get("/okr_view/:owner_id", Api.Analytics.OkrViewController, :show)
    end

    resources "/groups", Api.GroupController, only: [:index] do
      resources("/okrs", Api.OkrController, only: [:index])
    end

    resources "/users", Api.UserController, only: [:index] do
      resources("/okrs", Api.OkrController, only: [:index])
    end
  end

  if Mix.env == :dev do
    # If using Phoenix
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  # Must be defined at end to avoid catch-all getting other routes
  scope "/", OkrAppWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/*path", PageController, :index)
  end
end
