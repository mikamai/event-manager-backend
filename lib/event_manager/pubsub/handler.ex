defmodule EventManager.PubSub.Handler do
  @moduledoc """
    Behaviour for async handlers, using Phoenix.PubSub
  """

  @doc """
  Handle a message from the subscribed topic

  ## Examples

      use EventManager.PubSub.Handler, topic: "event:created"

      @impl true
      def handle({:event_created, event}) do
        Logger.info("[event:created] Received event: \#{inspect(event)}")
      end

  """
  @callback handle({atom(), any()}) :: :ok | {:error, String.t()}

  defmacro __using__(topic: topic) do
    quote do
      use GenServer
      @behaviour EventManager.PubSub.Handler

      def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, opts, name: __MODULE__)
      end

      # Callbacks

      @impl true
      def init(state) do
        :ok = Phoenix.PubSub.subscribe(EventManager.PubSub, unquote(topic))
        {:ok, state}
      end

      @impl true
      def handle_info(message, state) do
        handle(message)
        {:noreply, state}
      end
    end
  end
end
