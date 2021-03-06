defmodule EventManager.PubSub.Handlers do
  @moduledoc """
    Supervisor that starts async PubSub handlers
  """

  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(handlers) do
    Supervisor.init(handlers, strategy: :one_for_one)
  end
end
