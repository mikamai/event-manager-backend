defmodule EventManagerWeb.Resolvers.Event do
  alias Phoenix.PubSub
  alias EventManager.Events
  import EventManagerWeb.Gettext

  def get_event(%{id: ""}, _info) do
    {:error, "event.not_found"}
  end

  def get_event(%{id: id}, _info) when is_binary(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
         event when not is_nil(event) <- Events.get_event(uuid) do
      {:ok, event}
    else
      _ -> {:error, dgettext("errors", "Event not found by id %{id}", id: id)}
    end
  end

  def get_event(%{id: id}, _info) do
    case EventManager.Repo.get(Event, id) do
      nil -> {:error, "event.not_found"}
      event -> {:ok, event}
    end
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
  def create_event(args, %{context: %{current_user: nil}}) do
    {:error, dgettext("errors", "Unauthorized")}
  end

  def create_event(%{event: event}, _info) do
    case Map.put(event, :status, :draft) |> Events.create_event() do
      {:ok, struct} ->
        PubSub.broadcast(EventManager.PubSub, "user:created", {:user_created, struct})
        {:ok, struct}

      {:error, changeset} ->
        {:error, changeset.errors}
    end
  end

  @spec delete_event(
          %{event: :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}},
          any
        ) :: {:error, any} | {:ok, any}
  def delete_event(params, info) do
    with {:ok, event} <- get_event(params, info),
         {:ok, deleted} <- do_delete(event) do
      {:ok, deleted}
    else
      {:error, errors} -> {:error, errors}
    end
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
end
