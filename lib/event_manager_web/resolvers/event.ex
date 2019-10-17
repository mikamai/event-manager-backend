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
end
