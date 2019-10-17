defmodule EventManagerWeb.Schema.Event do
  use Absinthe.Schema.Notation

  import_types(EventManagerWeb.Types.Event)

  object :event_queries do
    @desc "Get a new event"
    field :event, :event do
      arg(:id, non_null(:id))
      resolve(&EventManagerWeb.Resolvers.Event.get_event/2)
    end
  end

  object :event_mutations do
    @desc "Create a new event"
    field :event_create, :event do
      arg(:event, non_null(:event_create_input))

      resolve(&EventManagerWeb.Resolvers.Event.create_event/2)
    end

    @desc "Delete an event"
    field :event_delete, :event do
      arg(:id, non_null(:id))

      resolve(&EventManagerWeb.Resolvers.Event.delete_event/2)
    end
  end
end
