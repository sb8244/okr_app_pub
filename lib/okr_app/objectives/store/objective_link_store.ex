defmodule OkrApp.Objectives.ObjectiveLinkStore do
  use OkrApp.Store.SimpleEctoStore, schema: OkrApp.Objectives.ObjectiveLink, only: [:all]
end
