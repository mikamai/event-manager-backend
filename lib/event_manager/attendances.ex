defmodule EventManager.Attendances do
  @moduledoc """
  The Attendances context.
  """

  import Ecto.Query, warn: false
  alias EventManager.Repo

  alias EventManager.Attendances.Attendance

  @doc """
  Returns the list of attendances.

  ## Examples

      iex> list_attendances()
      [%Attendance{}, ...]
  """
  def list_attendances, do: Repo.all(Attendance)

  @doc """
  Gets a single attendance.

  Raises `Ecto.NoResultsError` if the Attendance does not exist.

  ## Examples

      iex> get_attendance!(123)
      %Attendance{}

      iex> get_attendance!(456)
      ** (Ecto.NoResultsError)
  """
  def get_attendance!(id), do: Repo.get!(Attendance, id)

  @doc """
  Creates a attendance.

  ## Examples

      iex> create_attendance(%{field: value})
      {:ok, %Attendance{}}

      iex> create_attendance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_attendance(attrs \\ %{})

  def create_attendance(%{event_id: event_id} = attrs) when not is_nil(event_id) do
    event = EventManager.Events.get_event(event_id) # load event's creator and attendees?

    %Attendance{}
    |> Attendance.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:event, event)
    |> Repo.insert()
  end

  def create_attendance(attrs) do
    %Attendance{}
    |> Attendance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a attendance.

  ## Examples

      iex> update_attendance(attendance, %{field: new_value})
      {:ok, %Attendance{}}

      iex> update_attendance(attendance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_attendance(%Attendance{} = attendance, attrs) do
    attendance
    |> Attendance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Attendance.

  ## Examples

      iex> delete_attendance(attendance)
      {:ok, %Attendance{}}

      iex> delete_attendance(attendance)
      {:error, %Ecto.Changeset{}}
  """
  def delete_attendance(%Attendance{} = attendance) do
    Repo.delete(attendance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking attendance changes.

  ## Examples

      iex> change_attendance(attendance)
      %Ecto.Changeset{source: %Attendance{}}
  """
  def change_attendance(%Attendance{} = attendance) do
    Attendance.changeset(attendance, %{})
  end
end
