defmodule EventManagerWeb.Resolvers.Events do
  alias Phoenix.PubSub
  alias EventManager.Events
  alias EventManager.Users
  import EventManagerWeb.Gettext

  def get_event(params, _info) do
    do_get_event(params, &Events.get_event/1)
  end

  def events(pagination_args, _info) do
    {:ok, _direction, limit} = Absinthe.Relay.Connection.limit(pagination_args)
    {:ok, offset} = Absinthe.Relay.Connection.offset(pagination_args)

    Events.list_events(limit, offset)
    |> Absinthe.Relay.Connection.from_slice(offset)
  end

  @spec create_event(
          %{event: :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}},
          any
        ) :: {:error, any} | {:ok, any}
  def create_event(_args, %{context: %{current_user: nil}}) do
    {:error, dgettext("errors", "Unauthorized")}
  end

  def create_event(%{event: event}, %{context: %{current_user: current_user}}) do
    case Map.put(event, :status, :draft)
         |> Map.put(:creator, current_user)
         |> Events.create_event() do
      {:ok, created} ->
        created |> Ecto.assoc(:creator)
        PubSub.broadcast(EventManager.PubSub, "event:created", {:event_created, created})
        {:ok, created}

      {:error, changeset} ->
        {:error, changeset.errors}
    end
  end

  @spec delete_event(
          %{event: :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}},
          any
        ) :: {:error, any} | {:ok, any}
  def delete_event(params, %{context: %{current_user: current_user}}) do
    with {:ok, event} <- do_get_event(params, &Users.get_created_event(current_user, &1)),
         {:ok, deleted} <- do_delete(event) do
      {:ok, deleted}
    else
      {:error, errors} -> {:error, errors}
    end
  end

  def event_creator(event, _, _) do
    creator = EventManager.Events.get_event_creator(event)
    {:ok, creator}
  end

  defp do_delete(%Events.Event{status: :draft} = event) do
    case Events.delete_event(event) do
      {:ok, deleted} -> {:ok, deleted}
      {:error, changeset} -> {:error, changeset.errors}
    end
  end

  defp do_delete(%Events.Event{status: status}),
    do:
      {:error,
       dgettext("errors", "Only drafted events can be deleted. Current status: %{status}",
         status: status
       )}

  defp do_get_event(%{id: ""}, _) do
    {:error, "event.not_found"}
  end

  #  @spec do_get_event(Map.t(), )
  defp do_get_event(%{id: id}, get_fun) when is_binary(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
         event when not is_nil(event) <- get_fun.(uuid) do
      {:ok, event}
    else
      _ -> {:error, dgettext("errors", "Event not found by id %{id}", id: id)}
    end
  end
end
