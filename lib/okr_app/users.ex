defmodule OkrApp.Users do
  alias OkrApp.Repo
  alias OkrApp.Users.{Group, GroupStore, GroupUser, User, UserPreloader, UserStore}

  defdelegate get_active_user(opts), to: UserStore
  defdelegate get_user_by(opts), to: UserStore
  defdelegate all(params, opts \\ []), to: UserStore
  defdelegate find_user(id), to: UserStore, as: :find

  defdelegate all_groups(params, opts \\ []), to: GroupStore, as: :all
  defdelegate find_group(id), to: GroupStore, as: :find

  defdelegate preload_users(users, type), to: UserPreloader, as: :preload

  defdelegate get_sendable_email(user), to: User
  defdelegate user_slug(user), to: User, as: :slug

  def create_group(params) do
    Group.changeset(params)
    |> Repo.insert()
  end

  def insert_user_in_group(%User{id: user_id}, %Group{id: group_id}) do
    %{
      group_id: group_id,
      user_id: user_id
    }
    |> GroupUser.changeset()
    |> Repo.insert(on_conflict: :nothing, conflict_target: [:group_id, :user_id])
    |> case do
      {:ok, %{id: nil}} ->
        {:ok, Repo.get_by!(GroupUser, group_id: group_id, user_id: user_id)}

      ret ->
        ret
    end
  end
end
