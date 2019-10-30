defmodule EventManager.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias EventManager.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import EventManager.DataCase
    end
  end

  setup tags do
    alias Ecto.Adapters.SQL.Sandbox

    :ok = Sandbox.checkout(EventManager.Repo)

    unless tags[:async] do
      Sandbox.mode(EventManager.Repo, {:shared, self()})
    end

    :ok
  end

  alias EventManager.{Events, Users}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: attrs[:name] || "Fake User",
        email: "user@example.com",
        first_name: "Fake",
        last_name: "User",
        locale: "en",
        username: "user",
        id: Ecto.UUID.generate()
      })
      |> Users.create_user()

    user
  end

  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        title: attrs[:title] || "Fake Event",
        description: "A fake event",
        location: "Here",
        start_time: DateTime.utc_now() |> DateTime.truncate(:second),
        end_time: DateTime.utc_now() |> DateTime.truncate(:second)
      })
      |> Events.create_event()

    event
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(
      changeset,
      fn {message, opts} ->
        Regex.replace(
          ~r"%{(\w+)}",
          message,
          fn _, key ->
            opts
            |> Keyword.get(String.to_existing_atom(key), key)
            |> to_string()
          end
        )
      end
    )
  end
end
