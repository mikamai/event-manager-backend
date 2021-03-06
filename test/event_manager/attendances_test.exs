defmodule EventManager.AttendancesTest do
  use EventManager.DataCase

  alias EventManager.Attendances

  describe "attendances" do
    alias EventManager.Attendances.Attendance

    setup do
      creator = user_fixture()
      event = event_fixture(%{creator: creator, status: :published, title: "Test Event"})
      attendee = user_fixture(name: "Test Attendee")

      {
        :ok,
        valid_user: %{attendee_id: attendee.id, event_id: event.id, email: "@ignore"},
        valid_email: %{email: "@test", event_id: event.id},
        update_email: %{email: "@new", event_id: event.id},
        invalid_attrs: %{event_id: nil},
        invalid_user: %{attendee_id: 1, event_id: nil},
        unknown_user: %{attendee_id: Ecto.UUID.generate(), event_id: event.id},
        unknown_event: %{attendee_id: attendee.id, event_id: Ecto.UUID.generate()}
      }
    end

    def attendance_fixture(attrs \\ %{}) do
      {:ok, attendance} = Attendances.create_attendance(attrs)
      attendance
    end

    #
    # CREATE WITH EMAIL
    #

    test "create attendance given a valid email", %{valid_email: valid_email} do
      assert {:ok, attendance} = Attendances.create_attendance(valid_email)
      assert attendance.email == "@test"
    end

    test "new attendance loads the event", %{valid_email: valid_email} do
      assert {:ok, attendance} = Attendances.create_attendance(valid_email)
      attendance = Repo.preload(attendance, :event)
      assert attendance.event.title == "Test Event"
    end

    #
    # CREATE WITH USER ID
    #

    test "create attendance given a valid user id", %{valid_user: valid_user} do
      assert {:ok, attendance} = Attendances.create_attendance(valid_user)
      assert attendance.email == nil
      assert attendance.attendee_id == valid_user.attendee_id
    end

    test "new attendance loads the user", %{valid_user: valid_user} do
      assert {:ok, attendance} = Attendances.create_attendance(valid_user)
      attendance = Repo.preload(attendance, :attendee)
      assert attendance.attendee.name == "Test Attendee"
    end

    test "errors when create attendance with invalid user id", %{invalid_user: invalid_user} do
      assert {:error, changeset} = Attendances.create_attendance(invalid_user)
      assert "is invalid" in errors_on(changeset).attendee_id
      assert "can't be blank" in errors_on(changeset).event_id
    end

    #
    # CREATE WITH NON EXISTENT DATA
    #

    test "create attendance with invalid data returns error", %{invalid_attrs: invalid_attrs} do
      assert {:error, changeset} = Attendances.create_attendance(invalid_attrs)
      assert "provide email OR user along the event" in errors_on(changeset).event_id
    end

    test "errors when create attendance with non existent event", %{unknown_event: unknown_event} do
      assert {:error, changeset} = Attendances.create_attendance(unknown_event)
      assert "does not exist" in errors_on(changeset).event_id
    end

    test "errors when create attendance with non existent user", %{unknown_user: unknown_user} do
      assert {:error, changeset} = Attendances.create_attendance(unknown_user)
      assert "does not exist" in errors_on(changeset).attendee_id
    end

    #
    # UPDATE
    #

    test "update attendance with valid data", %{
      valid_email: valid_email,
      update_email: update_email
    } do
      attendance = attendance_fixture(valid_email)
      assert {:ok, attendance} = Attendances.update_attendance(attendance, update_email)
      assert attendance.email == "@new"
    end

    test "update attendance with invalid data returns error", %{
      valid_email: valid_email,
      invalid_attrs: invalid_attrs
    } do
      attendance = attendance_fixture(valid_email)

      assert {:error, %Ecto.Changeset{}} =
               Attendances.update_attendance(attendance, invalid_attrs)
    end

    #
    # DELETE
    #

    test "delete_attendance/1", %{valid_email: valid_email} do
      attendance = attendance_fixture(valid_email)
      assert {:ok, %Attendance{}} = Attendances.delete_attendance(attendance)
      assert_raise Ecto.NoResultsError, fn -> Attendances.get_attendance!(attendance.id) end
    end

    #
    # CHANGESET
    #

    test "change_attendance/1 returns an attendance changeset", %{valid_email: valid_email} do
      attendance = attendance_fixture(valid_email)
      assert %Ecto.Changeset{} = Attendances.change_attendance(attendance)
    end
  end
end
