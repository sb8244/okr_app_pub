defmodule OkrAppWeb.Api.OkrController do
  use OkrAppWeb, :controller

  alias OkrApp.{Objectives, Users}
  alias OkrAppWeb.Serializer

  def index(conn = %{private: %{current_user: current_user}}, params) do
    track_view(user: current_user, owner: analytics_owner(params))

    data =
      Objectives.all_okrs(owner_params(params))
      |> Objectives.preload_okrs(:current_objectives_key_results_full)
      |> sort_okrs()
      |> Enum.map(&Serializer.Okr.to_map/1)

    conn
    |> json(%{data: data})
  end

  def create(conn, params) do
    with {:find_owner, {:ok, owner}} <- {:find_owner, get_owner(params)},
         {:create, {:ok, okr}} <- {:create, Objectives.create_okr(params, owner: owner)},
         {:preload, okr} <- {:preload, Objectives.preload_okrs(okr, :current_objectives_key_results_full)} do
      conn
      |> put_status(201)
      |> json(%{data: Serializer.Okr.to_map(okr)})
    else
      {_, {:error, changeset = %Ecto.Changeset{}}} ->
        conn
        |> put_status(422)
        |> json(%{data: Serializer.Unprocessable.to_map(changeset)})

      {:find_owner, {:error, _}} ->
        conn
        |> put_status(422)
        |> json(%{data: Serializer.Unprocessable.to_map(owner_type(params), "does not exist")})
    end
  end

  defp track_view(user: user, owner: owner = {_, _}) do
    {:ok, _} = OkrApp.Analytics.create_analytics_event!(:okr_view, owner: owner, user: user)
  end

  defp sort_okrs(okrs) do
    Enum.sort(okrs, fn %{cycle: %{ends_at: ends_at1}}, %{cycle: %{ends_at: ends_at2}} ->
      DateTime.compare(ends_at1, ends_at2) in [:gt, :eq]
    end)
  end

  defp owner_params(%{"user_id" => user_id}), do: %{"user_id" => user_id}

  defp owner_params(%{"group_id" => group_id}), do: %{"group_id" => group_id}

  defp get_owner(%{"user_id" => id}), do: Users.find_user(id)

  defp get_owner(%{"group_id" => id}), do: Users.find_group(id)

  defp owner_type(%{"user_id" => _}), do: :user

  defp owner_type(%{"group_id" => _}), do: :group

  defp analytics_owner(%{"user_id" => id}), do: {:user, id}

  defp analytics_owner(%{"group_id" => id}), do: {:group, id}
end
