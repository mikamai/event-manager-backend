defmodule EventManagerWeb.Schema.Event do
  use Absinthe.Schema.Notation

  import_types(EventManagerWeb.Types.Event)

  object :event_mutations do
    @desc "Create a new event"
    field :event_create, :event do
      arg(:event, non_null(:event_create_input))

      resolve(&EventManagerWeb.Resolvers.Event.create_event/2)
    end
  end
end
