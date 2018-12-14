use Mix.Config

config :btc_watcher, :enable_watcher, true
config :btc_watcher, :api_url, System.get_env("API_URL")

config :btc_watcher, BtcWatcherWeb.Endpoint,
  load_from_system_env: true,
  url: [scheme: "http", host: {:system, "HOST"}, port: {:system, "PORT"}],
  check_origin: false,
  server: true

config :logger, level: :info

config :sentry,
  dsn: "https://ed1f845d36d44772b99fb3b2d4bc1ef9@sentry.io/1324775",
  environment_name: :prod,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!,
  tags: %{
    env: "production"
  },
  included_environments: [:prod]
