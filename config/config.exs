# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :btc_watcher, BtcWatcherWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tJaGA0v92DV1HsEIgWdFVjo/9d31eKy6l/AYdTFu2YbCePlLCWsixPpxjjAnTti5",
  render_errors: [view: BtcWatcherWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: BtcWatcher.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :btc_watcher, :btc_ws_url, "wss://ws.blockchain.info/inv"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
