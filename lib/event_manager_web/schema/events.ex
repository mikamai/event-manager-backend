defmodule EventManagerWeb.Schema.Events do
  @moduledoc """
    Root queries, mutations and subscriptions
    for events
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema, :modern

  alias EventManagerWeb.Resolvers.{Events, Attendances}
  Absinthe.Relay.Connection.Notation
  import_types(EventManagerWeb.Types.Event)

  object :event_queries do
    @desc "Get a new event"
    field :event, :event do
      arg(:id, non_null(:id))
      resolve(&Events.get_event/2)
    end

    connection field(:events, node_type: :event) do
      resolve(&Events.events/2)
    end
  end

  object :event_mutations do
    @desc "Create a new event"
    field :event_create, :event do
      arg(:event, non_null(:event_create_input))

      resolve(&Events.create_event/2)
    end

    @desc "Delete an event"
    field :event_delete, :event do
      arg(:id, non_null(:id))

      resolve(&Events.delete_event/2)
    end

    @desc "Publish an event"
    field :event_publish, :event do
      arg(:id, non_null(:id))

      resolve(&Events.publish_event/2)
    end

    @desc "Cancel an event"
    field :event_cancel, :event do
      arg(:id, non_null(:id))

      resolve(&Events.cancel_event/2)
    end

    @desc "Attend an event"
    field :event_attend, :event do
      arg :event_id, non_null(:id)
      arg :email, :string

      resolve &Attendances.create_attendance/2
    end
  end
end
