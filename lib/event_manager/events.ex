defmodule EventManager.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias EventManager.Repo

  alias EventManager.Events.Event

  def data do
    Dataloader.Ecto.new(EventManager.Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events, do: Repo.all(Event)

  @doc """
  Returns a list of only published events.

  ## Examples

      iex> list_published_events()
      [%Event{}, ...]

  """
  def list_published_events do
    Event
    |> where_published()
    |> Repo.all()
  end

  @doc """
  Returns the paginated list of events.

  ## Examples

      iex> list_events(10, 1)
      [%Event{}, ...]

  """
  def list_events(limit, offset) do
    Event
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  @doc """
  Returns a list of only published events.

  ## Examples

      iex> list_published_events(10, 1)
      [%Event{}, ...]

  """
  def list_published_events(limit, offset) do
    Event
    |> where_published()
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Gets a single event.

  Returns `nil` if the Event does not exist.

  ## Examples

      iex> get_event(123)
      %Event{}

      iex> get_event(456)
      nil

  """
  def get_event(id), do: Repo.get(Event, id)

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{})

  def create_event(%{creator: creator} = attrs) do
    %Event{}
    |> Event.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:creator, creator)
    |> Repo.insert()
  end

  def create_event(attrs) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{source: %Event{}}

  """
  def change_event(%Event{} = event) do
    Event.changeset(event, %{})
  end

  def get_event_creator(%Event{} = event) do
    Ecto.assoc(event, :creator)
    |> Repo.one!()
  end

  defp where_published(queryable) do
    where(queryable, [q], q.status in ["published", "participations_closed"])
  end
end
