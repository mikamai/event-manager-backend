defmodule EventManager.Attendances.Attendance do
  @moduledoc """
  Represents an event attendance by a user account (attendee)
  or simply by an email address.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "attendances" do
    field :email, :string
    belongs_to :attendee, EventManager.Users.User, foreign_key: :attendee_id
    belongs_to :event, EventManager.Events.Event

    timestamps()
  end

  @doc false
  def changeset(attendance, attrs) do
    attendance
    |> cast(attrs, [:email, :event_id])
    |> validate_required([:event_id])
  end
end
