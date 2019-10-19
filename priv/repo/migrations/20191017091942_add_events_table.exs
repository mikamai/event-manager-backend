defmodule EventManager.Repo.Migrations.AddEventsTable do
  use Ecto.Migration

  def up do
    create table("events", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, null: false
      add :description, :string, null: false
      add :location, :string, null: false
      add :public, :boolean, null: false, default: true
      add :status, :string, null: false, default: "draft"
      add :start_time, :utc_datetime, null: false
      add :end_time, :utc_datetime, null: false

      timestamps()
    end
  end

  def down do
    drop table("events")
  end
end
