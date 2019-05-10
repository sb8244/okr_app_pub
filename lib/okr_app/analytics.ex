defmodule OkrApp.Analytics do
  alias OkrApp.Repo
  alias OkrApp.Analytics.{AnalyticsEvent, OkrLoadQuery, UserLoadQuery}

  defdelegate unique_user_count(opts), to: UserLoadQuery
  defdelegate total_active_user_count(), to: UserLoadQuery
  defdelegate users_with_active_objectives_count(), to: UserLoadQuery

  defdelegate distinct_okr_views(opts), to: OkrLoadQuery
  defdelegate total_okr_views(opts), to: OkrLoadQuery

  def create_analytics_event!(:user_load, user_name: user_name) do
    with {:ok, user} <- OkrApp.Users.get_user_by(user_name: user_name) do
      event_insert(%{"type" => "user_load"}, user: user)
    end
  end

  def create_analytics_event!(:okr_view, owner: {owner_type, owner_id}, user: user) when is_atom(owner_type) and not is_nil(owner_id) do
    event_insert(%{"type" => "okr_view", "metadata" => %{"owner_id" => owner_id, "owner_type" => owner_type}}, user: user)
  end

  defp event_insert(params, user: user) do
    AnalyticsEvent.changeset(params, user: user)
    |> Repo.insert()
  end
end
