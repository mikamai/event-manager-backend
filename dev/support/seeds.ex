defmodule EventManager.Seeds do
  alias EventManager.{Users, Events, Attendances, Repo}
  import Ecto.Query, only: [from: 2]

  #
  # HELPERS
  #

  def create_user(tag) do
    %Users.User{
      id: Ecto.UUID.generate(),
      email: "email#{tag}",
      name: "name#{tag}",
      username: "username#{tag}",
      first_name: "first_name#{tag}",
      last_name: "last_name#{tag}"
    }
    |> Repo.insert!()
  end

  def create_event(tag, creator) do
    %Events.Event{
      creator: creator,
      title: "title#{tag}",
      description: "description#{tag}",
      location: "location#{tag}",
      status: :published,
      start_time: DateTime.utc_now() |> DateTime.truncate(:second),
      end_time: DateTime.utc_now() |> DateTime.truncate(:second)
    }
    |> Repo.insert!()
  end

  def first_by(queryable, field) do
    where = [{field, "#{field}1"}]
    Repo.one(from queryable, where: ^where)
  end

  def run do
    #
    # CLEAN DATABASE
    #

    Repo.delete_all(Attendances.Attendance)
    Repo.delete_all(Events.Event)
    Repo.delete_all(Users.User)

    #
    # CREATE USERS
    #

    Enum.each(1..5, &create_user(&1))

    #
    # CREATE EVENTS
    #

    creator = first_by(Users.User, :name)
    Enum.each(1..5, &create_event(&1, creator))

    #
    # CREATE ATTENDANCES
    #

    [_creator | others] = Repo.all(Users.User)
    event1 = first_by(Events.Event, :title)
    Enum.each(
      others,
      fn other ->
        %Attendances.Attendance{
          attendee: other,
          event: event1
        }
        |> Repo.insert!()
      end
    )
  end
end
