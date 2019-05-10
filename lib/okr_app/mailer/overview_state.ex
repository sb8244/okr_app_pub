defmodule OkrApp.Mailer.OverviewState do
  @enforce_keys [:cycle_title, :loaded_objectives, :recipient]
  defstruct @enforce_keys
end
