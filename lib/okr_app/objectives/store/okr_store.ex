defmodule OkrApp.Objectives.OkrStore do
  alias OkrApp.Objectives.Okr
  alias OkrApp.Repo

  use OkrApp.Store.SimpleEctoStore, schema: Okr, only: [:all]

  def create(params, owner: owner) do
    Okr.create_changeset(params, owner: owner)
    |> Repo.insert()
  end
end
