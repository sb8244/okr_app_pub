defmodule OkrApp.Analytics.OkrLoadQuery do
  alias OkrApp.Repo
  import Ecto.Query

  alias OkrApp.Analytics.{AnalyticsEvent}

  def distinct_okr_views(owner: %{id: owner_id}, days: days) when is_integer(days) do
    date = Timex.now() |> Timex.shift(days: -days)

    from(
      a in AnalyticsEvent,
      where: a.type == "okr_view",
      where: a.inserted_at > ^date,
      where: fragment("?->>'owner_id' = ?", a.metadata, ^owner_id),
      select: count(a.user_id, :distinct)
    )
    |> Repo.one()
  end

  def total_okr_views(owner: %{id: owner_id}, days: days) when is_integer(days) do
    date = Timex.now() |> Timex.shift(days: -days)

    from(
      a in AnalyticsEvent,
      where: a.type == "okr_view",
      where: a.inserted_at > ^date,
      where: fragment("?->>'owner_id' = ?", a.metadata, ^owner_id),
      select: count(a.user_id)
    )
    |> Repo.one()
  end
end
