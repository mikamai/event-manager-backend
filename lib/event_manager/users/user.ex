defmodule EventManager.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :name, :string
    field :username, :string
    field :first_name, :string
    field :last_name, :string
    has_many :created_events, EventManager.Events.Event, foreign_key: :creator_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :email, :name, :username, :first_name, :last_name])
    |> validate_required([:id, :email, :name, :username, :first_name, :last_name])
  end
end
