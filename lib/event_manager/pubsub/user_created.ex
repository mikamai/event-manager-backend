defmodule EventManager.PubSub.UserCreated do
  use EventManager.PubSub.Handler, topic: "user:created"
  require Logger

  @impl true
  def handle({:user_created, user}) do
    Logger.info("[user:created] Received event: #{inspect(user)}")
  end
end
