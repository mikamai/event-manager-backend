import Config

# Configure your database
config :event_manager, EventManager.Repo,
  username: "event_manager",
  password: "event_manager",
  database: "event_manager_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :event_manager, EventManagerWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :event_manager, :openid_connect_providers,
  keycloak: [
    discovery_document_uri:
      "http://localhost:8080/auth/realms/event-manager/.well-known/openid-configuration",
    client_id: "em-backend",
    client_secret: "secret",
    redirect_uri: "http://localhost:4000",
    response_type: "code",
    scope: "openid email profile"
  ]
