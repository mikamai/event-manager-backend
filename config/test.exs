import Config

# Configure your database
config :event_manager,
       EventManager.Repo,
       username: "event_manager",
       password: "event_manager",
       database: "event_manager_test",
       hostname: "localhost",
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
         discovery_document_uri:
           "http://localhost:8080/auth/realms/event-manager/.well-known/openid-configuration",
         client_id: "em-backend",
         client_secret: "secret",
         redirect_uri: "http://localhost:4000",
         response_type: "code",
         scope: "openid email profile"
       ]
