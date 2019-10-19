import Config

config :gettext, :default_locale, System.get_env("DEFAULT_LOCALE", "it")

database_url = System.get_env("DATABASE_URL")
pool_size = String.to_integer(System.get_env("POOL_SIZE") || "10")

if database_url do
  config :event_manager, EventManager.Repo,
    url: database_url,
    pool_size: pool_size
else
  config :event_manager, EventManager.Repo,
    username: System.get_env("POSTGRES_USER"),
    password: System.get_env("POSTGRES_PASSWORD"),
    database: System.get_env("POSTGRES_DB"),
    hostname: System.get_env("POSTGRES_HOST"),
    pool_size: pool_size
end

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :event_manager, EventManagerWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base,
  server: true

discovery_document_uri =
  System.get_env("OIDC_DISCOVERY_URL") ||
    raise """
    """

client_secret =
  System.get_env("OIDC_CLIENT_SECRET") ||
    raise """
    """

config :event_manager, :openid_connect_providers,
  keycloak: [
    discovery_document_uri: discovery_document_uri,
    client_id: System.get_env("OIDC_CLIENT_ID") || "em-backend",
    client_secret: client_secret,
    # we don't care since we're an API
    redirect_uri: "http://localhost:4000",
    response_type: "code",
    scope: "openid email profile"
  ]
