defmodule EventManagerWeb.Schema.EventTest do
  use ExUnit.Case
  @schema EventManagerWeb.Schema

  @event_data """
    id
    title
    description
    endTime
    startTime
    status
    public
    location
  """

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EventManager.Repo)
    # Setting the shared mode must be done only after checkout
  end

  describe "mutation createEvent" do
    @mutation """
    mutation EventCreate($event: EventCreateInput!) {
      eventCreate(event: $event) { #{@event_data} }
    }
    """

    test "responds to a createEvent mutation" do
      event = %{
        "description" => "Test",
        "title" => "test",
        "location" => "here",
        "public" => true,
        "startTime" =>
          NaiveDateTime.utc_now()
          |> NaiveDateTime.truncate(:second)
          |> NaiveDateTime.to_iso8601(),
        "endTime" =>
          NaiveDateTime.utc_now()
          |> NaiveDateTime.truncate(:second)
          |> NaiveDateTime.to_iso8601()
      }

      {:ok, result} = Absinthe.run(@mutation, @schema, variables: %{"event" => event})

      assert %{
               data: %{
                 "eventCreate" => %{
                   "description" => description,
                   "endTime" => end_time,
                   "location" => location,
                   "public" => public,
                   "startTime" => start_time,
                   "status" => "DRAFT",
                   "title" => title
                 }
               }
             } = result

      assert description == event["description"]
      assert end_time == event["endTime"]
      assert location == event["location"]
      assert public == event["public"]
      assert start_time == event["startTime"]
      assert title == event["title"]
    end
  end
end
