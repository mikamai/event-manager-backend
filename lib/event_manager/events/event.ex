defmodule EventManager.Events.Event do
  @moduledoc """
    An event organized by a community
  """

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum

  alias EventManager.Users.User
  alias EventManager.Attendances.Attendance

  defenum(StatusEnum, ~w(draft published ended cancelled participations_closed))

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "events" do
    field :title, :string
    field :description, :string
    field :location, :string
    field :public, :boolean
    field :status, StatusEnum, default: "draft"
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    belongs_to :creator, User, foreign_key: :creator_id
    many_to_many :attendants, User, join_through: Attendance, join_keys: [event_id: :id, attendant_id: :id]

    timestamps()
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :description, :location, :public, :status, :start_time, :end_time])
    |> validate_required([:title, :description, :location, :status, :start_time, :end_time])
  end
end
