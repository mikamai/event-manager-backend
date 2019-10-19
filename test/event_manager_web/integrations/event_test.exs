defmodule EventManagerWeb.Schema.EventTest do
  use EventManager.DataCase

  alias EventManager.Events.Event

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

  def current_user(context \\ %{}),
    do: Map.put(context, :current_user, user_fixture())

  describe "mutation eventCreate" do
    @mutation """
    mutation EventCreate($event: EventCreateInput!) {
      eventCreate(event: $event) { #{@event_data} }
    }
    """

    test "responds to a eventCreate mutation" do
      event = %{
        "description" => "Test",
        "title" => "test",
        "location" => "here",
        "public" => true,
        "startTime" =>
          DateTime.utc_now()
          |> DateTime.truncate(:second)
          |> DateTime.to_iso8601(),
        "endTime" =>
          DateTime.utc_now()
          |> DateTime.truncate(:second)
          |> DateTime.to_iso8601()
      }

      {:ok, result} =
        Absinthe.run(@mutation, @schema, variables: %{"event" => event}, context: current_user())

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

  describe "query event" do
    @query """
    query Event($id: ID!) {
      event(id: $id) { #{@event_data} }
    }
    """

    test "responds to the event query" do
      event = %Event{
        description: "Test",
        title: "test",
        location: "here",
        public: true,
        status: :draft,
        start_time: DateTime.utc_now() |> DateTime.truncate(:second),
        end_time: DateTime.utc_now() |> DateTime.truncate(:second)
      }

      event = EventManager.Repo.insert!(event)

      {:ok, result} = Absinthe.run(@query, @schema, variables: %{"id" => event.id})

      assert %{
               data: %{
                 "event" => %{
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

      assert title == event.title
      assert description == event.description
      assert location == event.location
      assert public == event.public
      assert end_time == event.end_time |> DateTime.to_iso8601()
      assert start_time == event.start_time |> DateTime.to_iso8601()
    end

    test "responds not found for an nonexistent event" do
      uuid = "550e8400-e29b-41d4-a716-446655440000"
      {:ok, result} = Absinthe.run(@query, @schema, variables: %{"id" => uuid})
      message = "event not found by id #{uuid}"

      assert %{
               data: %{"event" => nil},
               errors: [
                 %{
                   message: error,
                   path: ["event"]
                 }
               ]
             } = result

      assert error == message
    end
  end

  describe "mutation deleteEvent" do
    @mutation """
    mutation EventDelete($id: ID!) {
      eventDelete(id: $id) { #{@event_data} }
    }
    """

    test "respond to the delete event mutation" do
      context = current_user()

      event = %Event{
        description: "Test",
        title: "test",
        location: "here",
        public: true,
        status: :draft,
        start_time: DateTime.utc_now() |> DateTime.truncate(:second),
        end_time: DateTime.utc_now() |> DateTime.truncate(:second)
      }

      event =
        EventManager.Events.change_event(event)
        |> Ecto.Changeset.put_assoc(:creator, context.current_user)
        |> EventManager.Repo.insert!()

      {:ok, result} =
        Absinthe.run(@mutation, @schema, variables: %{"id" => event.id}, context: context)

      assert %{
               data: %{
                 "eventDelete" => %{
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

      assert title == event.title
      assert description == event.description
      assert location == event.location
      assert public == event.public
      assert end_time == event.end_time |> DateTime.to_iso8601()
      assert start_time == event.start_time |> DateTime.to_iso8601()
    end

    test "responds invalid status when the event is not in draft status" do
      context = current_user()

      event = %Event{
        description: "Test",
        title: "test",
        location: "here",
        public: true,
        status: :published,
        start_time: DateTime.utc_now() |> DateTime.truncate(:second),
        end_time: DateTime.utc_now() |> DateTime.truncate(:second)
      }

      event =
        EventManager.Events.change_event(event)
        |> Ecto.Changeset.put_assoc(:creator, context.current_user)
        |> EventManager.Repo.insert!()

      {:ok, result} =
        Absinthe.run(@mutation, @schema, variables: %{"id" => event.id}, context: context)

      assert %{
               data: %{"eventDelete" => nil},
               errors: [
                 %{
                   message: "only drafted events can be deleted. Current status: published",
                   path: ["eventDelete"]
                 }
               ]
             } = result
    end

    test "responds not found for an nonexistent event" do
      uuid = "550e8400-e29b-41d4-a716-446655440000"

      {:ok, result} =
        Absinthe.run(@mutation, @schema, variables: %{"id" => uuid}, context: current_user())

      message = "event not found by id #{uuid}"

      assert %{
               data: %{"eventDelete" => nil},
               errors: [
                 %{
                   message: error,
                   path: ["eventDelete"]
                 }
               ]
             } = result

      assert error == message
    end
  end

  describe "query events" do
    setup do
      [
        %Event{
          description: "Test1",
          title: "test1",
          location: "here",
          public: true,
          status: :draft,
          start_time: DateTime.utc_now() |> DateTime.truncate(:second),
          end_time: DateTime.utc_now() |> DateTime.truncate(:second)
        },
        %Event{
          description: "Test2",
          title: "test2",
          location: "here",
          public: true,
          status: :draft,
          start_time: DateTime.utc_now() |> DateTime.truncate(:second),
          end_time: DateTime.utc_now() |> DateTime.truncate(:second)
        }
      ]
      |> Enum.map(&Event.changeset/1)
      |> Enum.map(&EventManager.Repo.insert/1)
    end

    @query """
    query Events($first: Int, $after: String) {
      events(first: $first, after: $after) {
        edges { node { #{@event_data} } }
        pageInfo {
          hasPreviousPage
          hasNextPage
          startCursor
          endCursor
        }
      }
    }
    """

    test "responds to the events query when using first" do
      {:ok, result} = Absinthe.run(@query, @schema, variables: %{"first" => 1})

      assert %{
               data: %{
                 "events" => %{
                   "edges" => [
                     %{
                       "node" => %{
                         "title" => "test1"
                       }
                     }
                   ],
                   "pageInfo" => %{
                     "hasNextPage" => false,
                     "hasPreviousPage" => false,
                     "endCursor" => endCursor
                   }
                 }
               }
             } = result
    end

    test "responds to the events query when using first and after" do
      {:ok, result} = Absinthe.run(@query, @schema, variables: %{"first" => 1})
      %{data: %{"events" => %{"pageInfo" => %{"endCursor" => endCursor}}}} = result

      {:ok, result} =
        Absinthe.run(@query, @schema, variables: %{"first" => 1, "after" => endCursor})

      %{data: %{"events" => %{"edges" => [%{"node" => %{"title" => "test2"}}]}}} = result
    end
  end
end
