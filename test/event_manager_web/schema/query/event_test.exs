defmodule EventManagerWeb.Schema.Query.EventTest do
  use EventManagerWeb.ConnCase, async: true

  alias EventManager.Events

  setup do
    EventManager.Seeds.run()

    event_id =
      Events.Event
      |> EventManager.Seeds.first_by(:title)
      |> Map.fetch!(:id)

    {:ok, event_id: event_id}
  end

  @query """
  query ($id: ID!) {
    event(id: $id) {
      creator {
        name
      }
    }
  }
  """
  test "event field returns an event item", %{event_id: event_id} do
    variables = %{"id" => event_id}
    conn = post(build_conn(), "/graphql", query: @query, variables: variables)

    assert json_response(conn, 200) == %{
      "data" => %{
        "event" => %{
          "creator" => %{
            "name" => "name1"
          }
        }
      }
    }
  end
end
