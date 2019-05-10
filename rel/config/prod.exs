use Mix.Config

defmodule EnvMap do
  def fetch(key) do
    System.get_env(key)
  end

  def fetch!(key) do
    System.get_env(key) || (throw "#{key} not found in ENV")
  end
end

defmodule FileFromEnv do
  def create_okta_metadata do
    data =
      EnvMap.fetch!("SAML_BASE64_METADATA_XML")
      |> Base.decode64!()

    File.mkdir_p!("priv/idp")
    File.write!("priv/idp/okta_metadata.prod.xml", data)
    "priv/idp/okta_metadata.prod.xml"
  end
end

config :okr_app, OkrAppWeb.Endpoint,
  load_from_system_env: true,
  http: [
    protocol_options: [
      # Allow cookie header to be more than the default 4096
      max_header_value_length: 4096 * 4
    ]
  ],
  url: [host: EnvMap.fetch!("HOST"), port: 80],
  secret_key_base: EnvMap.fetch!("SECRET_KEY_BASE"),
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

# Configuration loaded in repo.ex
config :okr_app, OkrApp.Repo,
  pool_size: 25

config :okr_app,
  scim_auth: [
    username: EnvMap.fetch!("SCIM_AUTH_USERNAME"),
    password: EnvMap.fetch!("SCIM_AUTH_PASSWORD")
  ]

config :samly, Samly.Provider,
  idp_id_from: :path_segment,
  service_providers: [
    %{
      id: "okta-sp",
      entity_id: EnvMap.fetch!("SAML_ENTITY_ID")
    }
  ],
  identity_providers: [
    %{
      id: "okta",
      sp_id: "okta-sp",
      base_url: EnvMap.fetch!("SAML_BASE_URL"),
      metadata_file: FileFromEnv.create_okta_metadata(),
      pre_session_create_pipeline: OkrAppWeb.SamlyPipeline,
      allow_idp_initiated_flow: true,
      sign_requests: false,
      sign_metadata: false,
      signed_assertion_in_resp: false,
      signed_envelopes_in_resp: false
    }
  ]

config :statix,
  prefix: "okr_app.#{Mix.env()}",
  host: EnvMap.fetch("STATSD_HOST"),
  port: String.to_integer(System.get_env("STATSD_PORT") || "8125"),
  disabled: EnvMap.fetch("STATSD_HOST") == nil

config :okr_app, OkrApp.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: EnvMap.fetch("SENDGRID_API_KEY")

# Allow for custom configuration
import_config "./*_config.exs"
