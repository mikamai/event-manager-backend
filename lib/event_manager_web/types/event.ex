defmodule EventManagerWeb.Types.Event do
  @moduledoc """
    GraphQL types for Events
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema, :modern
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  input_object :event_create_input do
    field(:title, non_null(:string))
    field(:description, non_null(:string))
    field(:location, non_null(:string))
    field(:public, :boolean, default_value: false)
    field(:start_time, non_null(:datetime))
    field(:end_time, non_null(:datetime))
  end

  enum :event_state do
    description("Describe the event state")
    value(:draft, description: "Event is yet to be published")
    value(:published, description: "Event is published")
    value(:ended, description: "Event has ended")
    value(:cancelled, description: "Event has been cancelled")
  end

  object(:event) do
    field(:id, non_null(:id))
    field(:title, non_null(:string))
    field(:description, non_null(:string))
    field(:location, non_null(:string))
    field(:public, non_null(:boolean))
    field(:status, non_null(:event_state))
    field(:start_time, non_null(:datetime))
    field(:end_time, non_null(:datetime))

    field(:creator, non_null(:user), resolve: dataloader(EventManager.Events))
  end

  connection(node_type: :event)
end
