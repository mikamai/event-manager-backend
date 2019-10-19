defmodule EventManager.PubSub.EventCreated do
  use EventManager.PubSub.Handler, topic: "event:created"
  require Logger

  @impl true
  def handle({:event_created, event}) do
    Logger.info("[event:created] Received event: #{inspect(event)}")
  end
end
