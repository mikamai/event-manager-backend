defmodule EventManagerWeb.Resolvers.Event do
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
