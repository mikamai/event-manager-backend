defmodule EventManagerWeb.Types.Event do
  use Absinthe.Schema.Notation
  import_types(Absinthe.Type.Custom)

  input_object :event_create_input do
    field(:title, non_null(:string))
    field(:description, non_null(:string))
    field(:location, non_null(:string))
    field(:public, :boolean, default_value: false)
    field(:start_time, non_null(:naive_datetime))
    field(:end_time, non_null(:naive_datetime))
  end

  enum :event_state do
    description("Descibe the event state")
    value(:draft, description: "Event is yet to be published")
    value(:published, description: "Event is published")
    value(:ended, description: "Event has ended")
    value(:cancelled, description: "Event has been cacelled")
  end

  object(:event) do
    field(:id, non_null(:id))
    field(:title, non_null(:string))
    field(:description, non_null(:string))
    field(:location, non_null(:string))
    field(:public, non_null(:boolean))
    field(:status, non_null(:event_state))
    field(:start_time, non_null(:naive_datetime))
    field(:end_time, non_null(:naive_datetime))
    field(:inserted_at, non_null(:naive_datetime))
    field(:updated_at, non_null(:naive_datetime))
  end
end
