defmodule OkrApp.Objectives.OkrReflectionStore do
  use OkrApp.Store.SimpleEctoStore, schema: OkrApp.Objectives.OkrReflection, only: [:create, :find, :update]
end
