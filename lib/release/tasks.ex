defmodule Release.Tasks do
  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto
  ]

  @repo_module OkrApp.Repo

  def migrate do
    Application.load(:okr_app)
    Enum.each(@start_apps, &Application.ensure_all_started/1)
    @repo_module.start_link(pool_size: 1)
    run_migrations_for(@repo_module)
  end

  defp migrations_path, do: Application.app_dir(:okr_app, "priv/repo/migrations")

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    IO.puts("Running migrations for #{app}")
    Ecto.Migrator.run(repo, migrations_path(), :up, all: true)
  end
end
