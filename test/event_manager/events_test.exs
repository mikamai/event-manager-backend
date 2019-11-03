defmodule EventManager.EventsTest do
  use EventManager.DataCase

  alias EventManager.Events

  describe "events" do
    alias EventManager.Events.Event

    @valid_attrs %{
      description: "Test",
      title: "Test",
      location: "Here",
      status: :draft,
      start_time: DateTime.utc_now() |> DateTime.truncate(:second),
      end_time: DateTime.utc_now() |> DateTime.truncate(:second)
    }

    @update_attrs %{description: "New description"}

    @invalid_attrs %{
      description: "Test",
      title: "Test",
      location: "Here",
      public: "true",
      start_time: "false",
      end_time: 1
    }

    #
    # READ
    #

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "get_event/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event(event.id) == event
    end

    #
    # CREATE
    #

    test "create_event/1 with valid data creates a event" do
      assert {:ok, event} = Events.create_event(@valid_attrs)
      assert event.description == "Test"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    #
    # UPDATE
    #

    test "update_event/2 with valid data updates the event" do
      event = event_fixture(%{description: "Old description"})
      assert {:ok, event} = Events.update_event(event, @update_attrs)
      assert event.description == "New description"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    #
    # DELETE
    #

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    #
    # CHANGESET
    #

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
