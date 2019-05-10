defmodule Scim.Web.Router do
  use Phoenix.Router

  alias Scim.Web.{UsersController}

  get("/Users", UsersController, :index)
  get("/Users/:id", UsersController, :show)
  post("/Users", UsersController, :create)
  patch("/Users/:id", UsersController, :update)
  put("/Users/:id", UsersController, :update)
end
