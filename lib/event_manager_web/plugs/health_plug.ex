defmodule EventManagerWeb.HealthCheckPlug do
  @moduledoc """
    Adds an health check endpoint on `/health`
  """

  import Plug.Conn

  alias Ecto.Adapters.SQL

  def init(opts), do: opts

  def call(%Plug.Conn{request_path: "/health"} = conn, _opts) do
    SQL.query(EventManager.Repo, "SELECT 1")

    send_resp(conn, 200, "ok")
    |> halt()
  rescue
    e in DBConnection.ConnectionError -> send_resp(conn, 503, "Service Unavailable")
  end

  def call(conn, _opts), do: conn
end
