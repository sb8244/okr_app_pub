defmodule OkrApp.Users.UserPreloader do
  alias OkrApp.Repo

  def preload(users, :groups) do
    Repo.preload(users, :groups)
  end
end
