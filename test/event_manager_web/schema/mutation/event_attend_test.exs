defmodule EventManagerWeb.Schema.Mutation.EventAttendTest do
  use EventManagerWeb.ConnCase, async: true

  alias EventManager.Events

  import EventManager.DataCase, only: [user_fixture: 0]

  setup do
    EventManager.Seeds.run()

    event_id =
      Events.Event
      |> EventManager.Seeds.first_by(:title)
      |> Map.fetch!(:id)

    {:ok, event_id: event_id}
  end

  def current_user(context \\ %{}),
    do: Map.put(context, :current_user, user_fixture())

  @query """
  mutation($eventId: ID!, $email: String) {
    eventAttend(eventId: $eventId, email: $email) {
      title
    }
  }
  """
  test "eventAttend field sets an attendance given an email", %{event_id: event_id} do
    variables = %{"eventId" => event_id, "email" => "@"}
    conn = post(build_conn(), "/graphql", query: @query, variables: variables)

    assert json_response(conn, 200) == %{
      "data" => %{
        "eventAttend" => %{
          "title" => "title1"
        }
      }
    }
  end

  @query """
  mutation($eventId: ID!) {
    eventAttend(eventId: $eventId) {
      title
      attendees {
        name
      }
    }
  }
  """
  test "eventAttend field sets an attendance as the current user", %{event_id: event_id} do
    variables = %{"eventId" => event_id}
    conn =
      post(
        build_conn(),
        "/graphql",
        query: @query,
        variables: variables,
        context: current_user()
      )

    assert json_response(conn, 200) == %{
      "data" => %{
        "eventAttend" => %{
          "title" => "title1",
          "attendees" => [
            %{"name" => "name2"},
            %{"name" => "name3"},
            %{"name" => "name4"},
            %{"name" => "name5"},
            %{"name" => "Fake User"}
          ]
        }
      }
    }
  end
end
