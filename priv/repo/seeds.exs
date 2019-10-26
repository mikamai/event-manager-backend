import Ecto.Query, only: [from: 2]

alias EventManager.Users.User
alias EventManager.Events.Event
alias EventManager.Attendances.Attendance
alias EventManager.Repo

create_user = fn tag ->
  %User{
    id: Ecto.UUID.generate(),
    email: "email#{tag}",
    name: "name#{tag}",
    username: "username#{tag}",
    first_name: "first_name#{tag}",
    last_name: "last_name#{tag}"
  }
  |> Repo.insert!()
end

create_event = fn tag, creator ->
  %Event{
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

first_by = fn queryable, field ->
  where = [{field, "#{field}1"}]
  Repo.one(from resource in queryable, where: ^where)
end

Repo.delete_all(Attendance)
Repo.delete_all(Event)
Repo.delete_all(User)

Enum.each(1..5, &create_user.(&1))

creator = first_by.(User, :name)
Enum.each(1..5, &create_event.(&1, creator))

[_creator | others] = Repo.all(User)
event1 = first_by.(Event, :title)

Enum.each(
  others,
  fn other ->
    %Attendance{
      attendant: other,
      event: event1
    }
    |> Repo.insert!()
  end
)
