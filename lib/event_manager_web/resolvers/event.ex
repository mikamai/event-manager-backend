defmodule EventManagerWeb.Resolvers.Event do
  def get_event(%{id: id}, _info) do
    case EventManager.Repo.get(Event, id) do
      nil -> {:error, "event.not_found"}
      event -> {:ok, event}
    end
  end

  @spec create_event(
          %{event: :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}},
          any
        ) :: {:error, any} | {:ok, any}
  def create_event(%{event: event}, _info) do
    case %Event{status: :draft}
         |> Event.changeset(event)
         |> EventManager.Repo.insert() do
      {:ok, struct} ->
        {:ok, struct}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @spec delete_event(
          %{event: :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}},
          any
        ) :: {:error, any} | {:ok, any}
  def delete_event(%{id: id}, _info) do
    EventManager.Repo.get(Event, id) |> do_delete()
  end

  defp do_delete(nil), do: {:error, "event.not_found"}

  defp do_delete(%Event{status: :draft} = event) do
    case EventManager.Repo.delete(event) do
      {:ok, struct} ->
        {:ok, struct}

      {:error, _changeset} ->
        {:error, "event.generic_error"}
    end
  end

  defp do_delete(_), do: {:error, "event.invalid_status"}
end
