import Config

config :gettext, :default_locale, "en"

# Configure your database
config :event_manager,
       EventManager.Repo,
       username: "event_manager",
       password: "event_manager",
       database: "event_manager_test",
       hostname: System.get_env("POSTGRES_HOST") || "localhost",
       port: String.to_integer(System.get_env("POSTGRES_PORT") || "5432"),
       pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :event_manager,
       EventManagerWeb.Endpoint,
       http: [
         port: 4002
       ],
       server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :event_manager,
       :openid_connect_providers,
       keycloak: [
         discovery_document_uri: "https://samples.auth0.com/.well-known/openid-configuration",
         client_id: "test",
         client_secret: "test",
         redirect_uri: "http://localhost:4000",
         response_type: "code",
         scope: "openid email profile"
       ]
