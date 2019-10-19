defmodule EventManager.Repo.Migrations.AddLocaleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :locale, :string, null: false, default: Application.get_env(:gettext, :default_locale)
    end
  end
end
