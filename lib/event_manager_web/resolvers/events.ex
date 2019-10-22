defmodule EventManagerWeb.Resolvers.Events do
  @moduledoc """
    Resolvers for Event objects and related queries
  """

  alias Absinthe.Relay.Connection
  alias EventManager.Events
  alias EventManager.Users
  alias Phoenix.PubSub

  import EventManagerWeb.Gettext

  @max_per_page Application.get_env(:event_manager, :pagination, [])
                |> Keyword.get(:max_per_page, 50)

  def get_event(params, _info) do
    do_get_event(params, &Events.get_event/1)
  end

  def events(args, _info) do
    case Connection.offset_and_limit_for_query(args, max: @max_per_page) do
      {:ok, offset, limit} ->
        Events.list_events(limit, offset) |> Connection.from_slice(offset)

      {:error,
       "You must supply a count (total number of records) option if using `last` without `before`"} ->
        {:error, dgettext("errors", "`last` cannot be used without `before`")}

      {:error, error} ->
        {:error, Gettext.dgettext(EventManagerWeb.Gettext, "errors", error)}
    end
  end

  @spec create_event(
          %{event: :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}},
          any
        ) :: {:error, any} | {:ok, any}
  def create_event(_args, %{context: %{current_user: nil}}) do
    {:error, dgettext("errors", "unauthorized")}
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
  def delete_event(_args, %{context: %{current_user: nil}}) do
    {:error, dgettext("errors", "unauthorized")}
  end

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

  @spec publish_event(
          %{event: :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}},
          any
        ) :: {:error, any} | {:ok, any}
  def publish_event(_args, %{context: %{current_user: nil}}) do
    {:error, dgettext("errors", "unauthorized")}
  end

  def publish_event(params, %{context: %{current_user: current_user}}) do
    with {:ok, event} <- do_get_event(params, &Users.get_created_event(current_user, &1)),
         {:ok, published} <- do_publish(event) do
      {:ok, published}
    else
      {:error, errors} -> {:error, errors}
    end
  end

  @spec cancel_event(
          %{event: :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}},
          any
        ) :: {:error, any} | {:ok, any}
  def cancel_event(_args, %{context: %{current_user: nil}}) do
    {:error, dgettext("errors", "unauthorized")}
  end

  def cancel_event(params, %{context: %{current_user: current_user}}) do
    with {:ok, event} <- do_get_event(params, &Users.get_created_event(current_user, &1)),
         {:ok, cancelled} <- do_cancel(event) do
      {:ok, cancelled}
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
       dgettext("errors", "only drafted events can be deleted. Current status: %{status}",
         status: status
       )}

  defp do_publish(%Events.Event{status: :draft} = event) do
    case Events.update_event(event, %{status: :published}) do
      {:ok, published} -> {:ok, published}
      {:error, changeset} -> {:error, changeset.errors}
    end
  end

  defp do_publish(%Events.Event{status: status}),
    do:
      {:error,
       dgettext("errors", "only drafted events can be published. Current status: %{status}",
         status: status
       )}

  defp do_cancel(%Events.Event{status: :published} = event) do
    case Events.update_event(event, %{status: :cancelled}) do
      {:ok, cancelled} -> {:ok, cancelled}
      {:error, changeset} -> {:error, changeset.errors}
    end
  end

  defp do_cancel(%Events.Event{status: status}),
    do:
      {:error,
       dgettext("errors", "only published events can be cancelled. Current status: %{status}",
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
      _ -> {:error, dgettext("errors", "event not found by id %{id}", id: id)}
    end
  end
end
