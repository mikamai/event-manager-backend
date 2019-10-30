defmodule EventManager.Seeds do
  def run do
    alias EventManager.{Attendances, Events, Users, Repo}

    #
    # CLEAN DATABASE
    #

    Repo.delete_all(Attendances.Attendance)
    Repo.delete_all(Events.Event)
    Repo.delete_all(Users.User)

    #
    # CREATE USERS
    #

    michael =
      %Users.User{
        id: craft_id(),
        email: "michael@scott.com",
        first_name: "Michael",
        last_name: "Scott",
        name: "Michael Scott",
        username: "mscott"
      }
      |> Repo.insert!()

    dwight =
      %Users.User{
        id: craft_id(),
        email: "dwight@schrute.com",
        first_name: "Dwight",
        last_name: "Schrute",
        name: "Dwight Schrute",
        username: "dschrute"
      }
      |> Repo.insert!()

    jim =
      %Users.User{
        id: craft_id(),
        email: "jim@halpert.com",
        first_name: "Jim",
        last_name: "Halpert",
        name: "Jim Halpert",
        username: "jhalpert"
      }
      |> Repo.insert!()

    pam =
      %Users.User{
        id: craft_id(),
        email: "pam@beesly.com",
        first_name: "Pam",
        last_name: "Beesly",
        name: "Pam Beesly",
        username: "pbeesly"
      }
      |> Repo.insert!()

    #
    # CREATE EVENTS
    #

    diversity_day =
      %Events.Event{
        creator: michael,
        title: "Diversity Day",
        description: "A consultant will join us talk about tolerance and diversity",
        location: "The office",
        status: :published,
        start_time: time_now(),
        end_time: time_now()
      }
      |> Repo.insert!()

    _basketball_game =
      %Events.Event{
        creator: michael,
        title: "Basketball Game",
        description: "Us vs the warehouse workers",
        location: "The warehouse",
        status: :published,
        start_time: time_now(),
        end_time: time_now()
      }
      |> Repo.insert!()

    _office_olympics =
      %Events.Event{
        creator: michael,
        title: "Office Olympics",
        description: "Came up with a bunch of office games, let's play",
        location: "The office",
        status: :published,
        start_time: time_now(),
        end_time: time_now()
      }
      |> Repo.insert!()

    _take_your_daughter_to_work_day =
      %Events.Event{
        creator: michael,
        title: "Take Your Daughter To Work Day",
        description: "Let's show off how hard we work to our loved ones",
        location: "Dunder Mifflin",
        status: :published,
        start_time: time_now(),
        end_time: time_now()
      }
      |> Repo.insert!()

    _dinner_party =
      %Events.Event{
        creator: michael,
        title: "Dinner Party",
        description: "Couples-only dinner party",
        location: "Michael's home",
        status: :published,
        start_time: time_now(),
        end_time: time_now()
      }
      |> Repo.insert!()

    #
    # CREATE ATTENDANCES
    #

    Enum.each([dwight, jim, pam],
      fn u ->
        %Attendances.Attendance{
          attendee: u,
          event: diversity_day
        }
        |> Repo.insert!()
      end
    )

    :ok
  end

  defp time_now, do: DateTime.utc_now() |> DateTime.truncate(:second)
  defp craft_id, do: Ecto.UUID.generate()
end
