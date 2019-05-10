defmodule OkrApp.Objectives.KeyResultStore do
  use OkrApp.Store.SimpleEctoStore, schema: OkrApp.Objectives.KeyResult, only: [:create, :find, :update, :delete]
end
