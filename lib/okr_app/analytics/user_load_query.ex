defmodule OkrApp.Analytics.UserLoadQuery do
  alias OkrApp.Repo
  import Ecto.Query

  alias OkrApp.Users.{User}
  alias OkrApp.Analytics.{AnalyticsEvent}

  def unique_user_count(days: days) when is_integer(days) do
    date = Timex.now() |> Timex.shift(days: -days)

    from(
      a in AnalyticsEvent,
      join: u in assoc(a, :user),
      where: a.type == "user_load",
      where: a.inserted_at > ^date,
      where: u.active == true,
      select: count(a.user_id, :distinct)
    )
    |> Repo.one()
  end

  def users_with_active_objectives_count() do
    now = Timex.now()

    from(
      o in OkrApp.Objectives.Okr,
      join: u in assoc(o, :user),
      join: c in assoc(o, :cycle),
      join: obj in assoc(o, :objectives),
      where: u.active == true,
      where: c.starts_at < ^now and c.ends_at > ^now,
      where: is_nil(obj.deleted_at),
      select: count(u.id, :distinct)
    )
    |> Repo.one()
  end

  def total_active_user_count() do
    from(
      u in User,
      where: u.active == true,
      select: count(u.id, :distinct)
    )
    |> Repo.one()
  end
end
