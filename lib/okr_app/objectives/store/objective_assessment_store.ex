defmodule OkrApp.Objectives.ObjectiveAssessmentStore do
  use OkrApp.Store.SimpleEctoStore, schema: OkrApp.Objectives.ObjectiveAssessment, only: [:create, :find, :update]
end
