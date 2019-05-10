defmodule OkrApp.Mailer.OverviewCoordinator do
  alias OkrApp.{Objectives, Users}
  alias OkrApp.Mailer.{OverviewState, Recipient}

  @doc """
  Send out all overview mailings asynchronously
  """
  def execute_overview_mailings() do
    OkrApp.Mailer.OverviewCoordinator.load_mailer_states()
    |> Enum.each(fn mailer_state ->
      OkrApp.Mailer.Overview.generate(mailer_state)
      |> OkrApp.Mailer.deliver_later()
    end)
  end

  @doc """
  Provides a list of [%OverviewState{}] which represents all mailings that should be delivered and to whom.

  If there are multiple concurrent cycles, the user will receive an email for the cycle with objectives. If there
  are no objectives, they will receive 2 emails. This will probably change and is an unlikely documented quirk for
  now.
  """
  def load_mailer_states() do
    load_mailer_states(active_cycles(), active_users())
  end

  def load_mailer_states(cycles, users) when cycles == [] or users == [] do
    []
  end

  def load_mailer_states(cycles, users) do
    raw_okrs = okrs(cycles)
    okrs = grouped_okrs(raw_okrs)

    Enum.reduce(cycles, [], fn %{id: cycle_id, title: cycle_title}, all_states ->
      Enum.reduce(users, all_states, fn user = %{id: user_id}, cycle_states ->
        create_recipient(user)
        |> case do
          :error ->
            cycle_states

          {:ok, recipient} ->
            state =
              Map.get(okrs, grouping_key(cycle_id: cycle_id, user_id: user_id), [])
              |> case do
                [] ->
                  process_user_without_data(raw_okrs, user_id, cycle_title: cycle_title, recipient: recipient)

                [%{objectives: objectives} | _] ->
                  %OverviewState{cycle_title: cycle_title, loaded_objectives: objectives, recipient: recipient}
              end

            [state | cycle_states]
        end
      end)
    end)
    |> List.flatten()
  end

  defp process_user_without_data(okrs, user_id, cycle_title: cycle_title, recipient: recipient) do
    if Enum.any?(okrs, & &1.user_id == user_id) do
      []
    else
      %OverviewState{cycle_title: cycle_title, loaded_objectives: [], recipient: recipient}
    end
  end

  defp active_users(), do: Users.all(%{active: true})

  defp active_cycles(), do: Objectives.all_cycles(%{active: true})

  defp grouping_key(cycle_id: cycle, user_id: user) do
    {cycle, user}
  end

  defp okrs(cycles) do
    cycle_ids = Enum.map(cycles, & &1.id)

    Objectives.all_okrs(%{cycle_id: cycle_ids})
    |> Objectives.preload_okrs(:current_objectives_key_results_simple)
    |> Enum.flat_map(fn okr = %{objectives: objectives} ->
      if objectives == [] do
        []
      else
        [okr]
      end
    end)
  end

  defp grouped_okrs(okrs) do
    okrs
    |> Enum.group_by(& grouping_key(cycle_id: &1.cycle_id, user_id: &1.user_id))
  end

  defp create_recipient(user) do
    OkrApp.Users.get_sendable_email(user)
    |> case do
      {:ok, email} ->
        {:ok, %Recipient{
          to: email,
          first_name: Map.get(user, :given_name) || "OKR Ninja (no name available)",
          slug: OkrApp.Users.user_slug(user),
        }}

      {:error, :no_email} ->
        :error
    end
  end
end
