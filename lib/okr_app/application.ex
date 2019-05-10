defmodule OkrApp.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec
    setup_probes()

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(OkrApp.Repo, []),
      supervisor(OkrAppWeb.Endpoint, []),
      worker(Samly.Provider, []),
      worker(OkrApp.Scheduler, []),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OkrApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    OkrAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def setup_probes() do
    if Application.get_env(:instruments, :disabled) != true do
      {:ok, _} = Application.ensure_all_started(:instruments)
      interval = 1_000

      Instruments.Probe.define(
        "erlang.process_count",
        :gauge,
        mfa: {:erlang, :system_info, [:process_count]},
        report_interval: interval
      )

      Instruments.Probe.define(
        "erlang.memory",
        :gauge,
        mfa: {:erlang, :memory, []},
        keys: [:total, :atom, :processes, :binary, :ets],
        report_interval: interval
      )

      Instruments.Probe.define(
        "erlang.statistics.run_queue",
        :gauge,
        mfa: {:erlang, :statistics, [:run_queue]},
        report_interval: interval
      )

      Instruments.Probe.define(
        "erlang.system_info.process_count",
        :gauge,
        mfa: {:erlang, :system_info, [:process_count]},
        report_interval: interval
      )
    end
  end
end
