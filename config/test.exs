use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :okr_app, OkrAppWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :okr_app, OkrApp.Repo,
  username: System.get_env("DATABASE_USER") || "postgres",
  password: System.get_env("DATABASE_PASSWORD") || "postgres",
  database: "okr_app_test",
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :response_snapshot,
  path_base: "test/fixtures",
  ignored_keys: [
    {"id", :any_nesting},
    {"updated_at", :any_nesting},
    {"inserted_at", :any_nesting},
    {"cancelled_at", :any_nesting},
    {"starts_at", :any_nesting},
    {"ends_at", :any_nesting},
    {"owner.user_name", :any_nesting}
  ]

config :instruments, reporter_module: Instruments.StatsReporter.Logger
