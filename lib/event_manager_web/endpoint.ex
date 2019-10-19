defmodule EventManagerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :event_manager
  use Absinthe.Phoenix.Endpoint, schema: EventManagerWeb.Schema

  plug EventManagerWeb.HealthCheckPlug

  socket "/socket", EventManagerWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug EventManagerWeb.Router
end
