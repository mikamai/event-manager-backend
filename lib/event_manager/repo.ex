defmodule EventManager.Repo do
  use Ecto.Repo,
    otp_app: :event_manager,
    adapter: Ecto.Adapters.Postgres
end
