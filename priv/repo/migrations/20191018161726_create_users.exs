defmodule EventManager.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :name, :string, null: false
      add :username, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :locale, :string, null: false, default: Application.get_env(:gettext, :default_locale)

      timestamps()
    end

    unique_index(:users, :email)

    alter table(:events) do
      add :creator_id, references(:users)
    end
  end

  def down do
    drop table(:users)

    alter table(:events) do
      remove :creator_id
    end
  end
end
