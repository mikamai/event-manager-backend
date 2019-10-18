defmodule EventManager.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum

  defenum(StatusEnum, draft: 0, published: 1, ended: 2, cancelled: 3)

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "events" do
    field :title, :string
    field :description, :string
    field :location, :string
    field :public, :boolean
    field :status, StatusEnum
    field :start_time, :naive_datetime
    field :end_time, :naive_datetime

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
