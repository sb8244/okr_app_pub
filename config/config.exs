# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :okr_app,
  ecto_repos: [OkrApp.Repo],
  scim_auth: [
    username: "admin",
    password: "admin"
  ]

config :okr_app, OkrApp.Repo,
  adapter: Ecto.Adapters.Postgres,
  migration_timestamps: [type: :utc_datetime],
  timeout: 20_000,
  pool_timeout: 10_000

# Configures the endpoint
config :okr_app, OkrAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PdU5wq3Twwq6DG8b3wOqrAZQaOQ3XBH806SkcgqN1inx3i/RCZNQk0ZOeK9fx0XX",
  render_errors: [view: OkrAppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: OkrApp.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :instruments,
  fast_counter_report_interval: 100,
  probe_prefix: "probes"

config :okr_app, OkrApp.Mailer,
  deliver_later_strategy: OkrApp.Mailer.RetryLaterStrategy

config :okr_app, OkrApp.Scheduler,
  global: true,
  timezone: "America/New_York",
  timeout: 120_000,
  jobs: [
    # Every Monday at 8am EST
    {"0 8 * * 1", {OkrApp.Mailer.OverviewCoordinator, :execute_overview_mailings, []}},
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
