defmodule EventManager.PubSub.Handlers do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(arg) do
    children = [
      EventManager.PubSub.UserCreated
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end