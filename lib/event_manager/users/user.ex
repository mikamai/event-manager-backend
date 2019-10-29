defmodule EventManager.Users.User do
  @moduledoc """
    A user from the OpenID Connect provider
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias EventManager.{Events, Attendances}

  @default_locale Application.get_env(:gettext, :default_locale)
  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :name, :string
    field :username, :string
    field :first_name, :string
    field :last_name, :string
    field :locale, :string, default: @default_locale
    has_many :created_events, Events.Event, foreign_key: :creator_id

    many_to_many :events_to_attend, Events.Event,
      join_through: Attendances.Attendance,
      join_keys: [attendee_id: :id, event_id: :id]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :email, :name, :username, :first_name, :last_name, :locale])
    |> validate_required([:id, :email, :name, :username, :first_name, :last_name])
  end
end
