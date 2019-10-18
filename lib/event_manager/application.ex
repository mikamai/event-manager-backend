defmodule EventManager.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      EventManager.Repo,
      EventManagerWeb.Endpoint,
      {Absinthe.Subscription, [EventManagerWeb.Endpoint]},
      {OpenIDConnect.Worker, Application.get_env(:event_manager, :openid_connect_providers)},
      EventManager.PubSub.Handlers
    ]

    opts = [strategy: :one_for_one, name: EventManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EventManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
