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

    test "responds to an eventCreate mutation" do
      event = %{
        "description" => "Test",
        "title" => "test",
        "location" => "here",
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
                   "startTime" => start_time,
                   "status" => "DRAFT",
                   "title" => title
                 }
               }
             } = result

      assert description == event["description"]
      assert end_time == event["endTime"]
      assert location == event["location"]
      assert start_time == event["startTime"]
      assert title == event["title"]
    end
  end

  describe "query event" do
    defp events_by_statuses(statuses) do
      Enum.map(
        statuses,
        &%Event{
          description: "Test #{&1}",
          title: "test #{&1}",
          location: "here",
          status: &1,
          start_time: DateTime.utc_now() |> DateTime.truncate(:second),
          end_time: DateTime.utc_now() |> DateTime.truncate(:second)
        }
      )
      |> Enum.map(&Event.changeset/1)
      |> Enum.map(&EventManager.Repo.insert!/1)
      |> Enum.into(%{}, fn event -> {event.status, event} end)
    end

    @query """
    query Event($id: ID!) {
      event(id: $id) { #{@event_data} }
    }
    """

    @statuses ~w(draft published cancelled participations_closed)a

    test "doesn't find a drafted event" do
      %{draft: draft} = events_by_statuses(@statuses)

      {:ok, result} = Absinthe.run(@query, @schema, variables: %{"id" => draft.id})

      assert %{data: %{"event" => nil}} = result
    end

    test "finds a publish event" do
      %{published: published} = events_by_statuses(@statuses)

      {:ok, result} = Absinthe.run(@query, @schema, variables: %{"id" => published.id})

      assert %{
               data: %{
                 "event" => %{
                   "description" => description,
                   "endTime" => end_time,
                   "location" => location,
                   "startTime" => start_time,
                   "status" => "PUBLISHED",
                   "title" => title
                 }
               }
             } = result

      assert title == published.title
      assert description == published.description
      assert location == published.location
      assert end_time == published.end_time |> DateTime.to_iso8601()
      assert start_time == published.start_time |> DateTime.to_iso8601()
    end

    test "doesn't find a cancelled event" do
      %{cancelled: cancelled} = events_by_statuses(@statuses)

      {:ok, result} = Absinthe.run(@query, @schema, variables: %{"id" => cancelled.id})

      assert %{data: %{"event" => nil}} = result
    end

    test "finds an event with closed participations" do
      %{participations_closed: participations_closed} = events_by_statuses(@statuses)

      {:ok, result} =
        Absinthe.run(@query, @schema, variables: %{"id" => participations_closed.id})

      assert %{
               data: %{
                 "event" => %{
                   "description" => description,
                   "endTime" => end_time,
                   "location" => location,
                   "startTime" => start_time,
                   "status" => "PARTICIPATIONS_CLOSED",
                   "title" => title
                 }
               }
             } = result

      assert title == participations_closed.title
      assert description == participations_closed.description
      assert location == participations_closed.location
      assert end_time == participations_closed.end_time |> DateTime.to_iso8601()
      assert start_time == participations_closed.start_time |> DateTime.to_iso8601()
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

      event =
        %Event{
          description: "Test",
          title: "test",
          location: "here",
          status: :draft,
          start_time: DateTime.utc_now() |> DateTime.truncate(:second),
          end_time: DateTime.utc_now() |> DateTime.truncate(:second)
        }
        |> EventManager.Events.change_event()
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
                   "startTime" => start_time,
                   "status" => "DRAFT",
                   "title" => title
                 }
               }
             } = result

      assert title == event.title
      assert description == event.description
      assert location == event.location
      assert end_time == event.end_time |> DateTime.to_iso8601()
      assert start_time == event.start_time |> DateTime.to_iso8601()
    end

    test "responds invalid status when the event is not in draft status" do
      context = current_user()

      event =
        %Event{
          description: "Test",
          title: "test",
          location: "here",
          status: :published,
          start_time: DateTime.utc_now() |> DateTime.truncate(:second),
          end_time: DateTime.utc_now() |> DateTime.truncate(:second)
        }
        |> EventManager.Events.change_event()
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
      Enum.map(
        @statuses,
        &%Event{
          description: "Test #{&1}",
          title: "test #{&1}",
          location: "here",
          status: &1,
          start_time: DateTime.utc_now() |> DateTime.truncate(:second),
          end_time: DateTime.utc_now() |> DateTime.truncate(:second)
        }
      )
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
                         "title" => "test published"
                       }
                     }
                   ],
                   "pageInfo" => %{
                     # shouldn't this be true?
                     "hasNextPage" => false,
                     "hasPreviousPage" => false,
                     "endCursor" => _
                   }
                 }
               }
             } = result
    end

    test "responds to the events query when using first and after" do
      {:ok, result} = Absinthe.run(@query, @schema, variables: %{"first" => 1})

      assert %{
               data: %{
                 "events" => %{
                   "edges" => [
                     %{
                       "node" => %{
                         "title" => "test published"
                       }
                     }
                   ],
                   "pageInfo" => %{
                     "endCursor" => end_cursor
                   }
                 }
               }
             } = result

      {:ok, result} =
        Absinthe.run(@query, @schema, variables: %{"first" => 1, "after" => end_cursor})

      assert %{
               data: %{
                 "events" => %{
                   "edges" => [
                     %{
                       "node" => %{
                         "title" => "test participations_closed"
                       }
                     }
                   ]
                 }
               }
             } = result
    end
  end

  describe "mutation eventPublish" do
    @mutation """
    mutation EventPublish($id: ID!) {
      eventPublish(id: $id) { #{@event_data} }
    }
    """

    test "respond to the publish event mutation" do
      context = current_user()

      event = %Event{
        description: "Test",
        title: "test",
        location: "here",
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
                 "eventPublish" => %{
                   "description" => description,
                   "endTime" => end_time,
                   "location" => location,
                   "startTime" => start_time,
                   "status" => "PUBLISHED",
                   "title" => title
                 }
               }
             } = result

      assert title == event.title
      assert description == event.description
      assert location == event.location
      assert end_time == event.end_time |> DateTime.to_iso8601()
      assert start_time == event.start_time |> DateTime.to_iso8601()
    end

    test "responds invalid status when the event cannot be published" do
      context = current_user()

      event =
        %Event{
          description: "Test",
          title: "test",
          location: "here",
          status: :ended,
          start_time: DateTime.utc_now() |> DateTime.truncate(:second),
          end_time: DateTime.utc_now() |> DateTime.truncate(:second)
        }
        |> EventManager.Events.change_event()
        |> Ecto.Changeset.put_assoc(:creator, context.current_user)
        |> EventManager.Repo.insert!()

      {:ok, result} =
        Absinthe.run(@mutation, @schema, variables: %{"id" => event.id}, context: context)

      assert %{
               data: %{"eventPublish" => nil},
               errors: [
                 %{
                   message: "only drafted events can be published. Current status: ended",
                   path: ["eventPublish"]
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
               data: %{"eventPublish" => nil},
               errors: [
                 %{
                   message: error,
                   path: ["eventPublish"]
                 }
               ]
             } = result

      assert error == message
    end
  end

  describe "mutation eventCancel" do
    @mutation """
    mutation EventCancel($id: ID!) {
      eventCancel(id: $id) { #{@event_data} }
    }
    """

    test "respond to the cancel event mutation" do
      context = current_user()

      event =
        %Event{
          description: "Test",
          title: "test",
          location: "here",
          status: :published,
          start_time: DateTime.utc_now() |> DateTime.truncate(:second),
          end_time: DateTime.utc_now() |> DateTime.truncate(:second)
        }
        |> EventManager.Events.change_event()
        |> Ecto.Changeset.put_assoc(:creator, context.current_user)
        |> EventManager.Repo.insert!()

      {:ok, result} =
        Absinthe.run(@mutation, @schema, variables: %{"id" => event.id}, context: context)

      assert %{
               data: %{
                 "eventCancel" => %{
                   "description" => description,
                   "endTime" => end_time,
                   "location" => location,
                   "startTime" => start_time,
                   "status" => "CANCELLED",
                   "title" => title
                 }
               }
             } = result

      assert title == event.title
      assert description == event.description
      assert location == event.location
      assert end_time == event.end_time |> DateTime.to_iso8601()
      assert start_time == event.start_time |> DateTime.to_iso8601()
    end

    test "responds invalid status when the event cannot be cancelled" do
      context = current_user()

      event =
        %Event{
          description: "Test",
          title: "test",
          location: "here",
          status: :ended,
          start_time: DateTime.utc_now() |> DateTime.truncate(:second),
          end_time: DateTime.utc_now() |> DateTime.truncate(:second)
        }
        |> EventManager.Events.change_event()
        |> Ecto.Changeset.put_assoc(:creator, context.current_user)
        |> EventManager.Repo.insert!()

      {:ok, result} =
        Absinthe.run(@mutation, @schema, variables: %{"id" => event.id}, context: context)

      assert %{
               data: %{"eventCancel" => nil},
               errors: [
                 %{
                   message: "only published events can be cancelled. Current status: ended",
                   path: ["eventCancel"]
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
               data: %{"eventCancel" => nil},
               errors: [
                 %{
                   message: error,
                   path: ["eventCancel"]
                 }
               ]
             } = result

      assert error == message
    end
  end

  describe "mutation eventAttend" do
    @mutation """
    mutation($eventId: ID!, $email: String) {
      eventAttend(eventId: $eventId, email: $email) { #{@event_data} }
    }
    """

    test "accepts an email" do
      event = event_fixture(status: :published)
      variables = %{"eventId" => event.id, "email" => "@"}

      {:ok, result} = Absinthe.run(@mutation, @schema, variables: variables)

      assert %{
          data: %{
            "eventAttend" => %{
              "description" => description,
              "endTime" => end_time,
              "location" => location,
              "startTime" => start_time,
              "status" => "PUBLISHED",
              "title" => title
            }
          }
        } = result

      assert description == event.description
      assert end_time == event.end_time |> DateTime.to_iso8601()
      assert location == event.location
      assert start_time == event.start_time |> DateTime.to_iso8601()
      assert title == event.title
    end
  end
end
