defmodule EventManager.Repo.Migrations.AddEventsTable do
  use Ecto.Migration

  def up do
    create table("events", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :description, :string
      add :location, :string
      add :public, :boolean
      add :status, :integer
      add :start_time, :naive_datetime
      add :end_time, :naive_datetime

      timestamps()
    end
  end

  def down do
    drop table("events")
  end
end
