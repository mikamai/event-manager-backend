defmodule EventManager.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :name, :string, null: false
      add :username, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      timestamps()
    end

    unique_index(:users, :email)

    alter table(:events) do
      add :creator_id, references(:users)
    end
  end
end
