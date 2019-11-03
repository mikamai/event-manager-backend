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
  def changeset(struct, %{attendee_id: _} = attrs), do: user_changeset(struct, attrs)
  def changeset(struct, %{email: _} = attrs), do: email_changeset(struct, attrs)

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:event_id])
    |> add_error(:event_id, "provide email OR user along the event")
  end

  defp user_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:event_id, :attendee_id])
    |> validate_required([:event_id, :attendee_id])
    |> foreign_key_constraint(:attendee_id)
    |> foreign_key_constraint(:event_id)
  end

  defp email_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:event_id, :email])
    |> validate_required([:event_id, :email])
    |> foreign_key_constraint(:event_id)
  end
end
