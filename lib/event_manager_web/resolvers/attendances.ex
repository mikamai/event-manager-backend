defmodule EventManagerWeb.Resolvers.Attendances do
  @moduledoc """
  Resolvers for Attendance objects and related queries.
  """

  # alias Absinthe.Relay.Connection
  alias EventManager.Attendances
  # alias Phoenix.PubSub

  # import EventManagerWeb.Gettext

  def create_attendance(args, %{context: %{current_user: current_user}}) do
    case Map.put(args, :attendee, current_user)
         |> Attendances.create_attendance() do
      {:ok, attendance} ->
        # attendance = Repo.preload(attendance, [:attendee, :event])
        {:ok, attendance.event}

      {:error, changeset} ->
       {:error, changeset.errors}
    end
  end

  def create_attendance(args, _info) do
    case Attendances.create_attendance(args) do
      {:ok, attendance} ->
        attendance = EventManager.Repo.preload(attendance, :event)
        {:ok, attendance.event}

      {:error, changeset} ->
        {:error, changeset.errors}
    end
  end
end
