# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :event_manager,
  ecto_repos: [EventManager.Repo],
  generators: [binary_id: true]

config :event_manager, EventManager.Repo, migration_primary_key: [name: :uuid, type: :binary_id]

# Configures the endpoint
config :event_manager, EventManagerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pDzfqrrHOdvJW3klbU1FxZB8zNPbvYT0QsAEto1FcGwCjniD3GeeYdSprL1MM+lM",
  render_errors: [view: EventManagerWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: EventManager.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
