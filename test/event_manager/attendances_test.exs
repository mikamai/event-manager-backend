defmodule EventManager.AttendancesTest do
  use EventManager.DataCase

  alias EventManager.{Attendances, Events}

  describe "attendances" do
    alias EventManager.Attendances.Attendance

    setup do
      EventManager.Seeds.run()

      event_id =
        Events.Event
        |> EventManager.Seeds.first_by(:title)
        |> Map.fetch!(:id)

      {
        :ok,
        valid_attrs: %{email: "@example.com", event_id: event_id},
        update_attrs: %{email: "@example.io", event_id: event_id},
        invalid_attrs: %{event_id: nil}
      }
    end

    def attendance_fixture(attrs \\ %{}) do
      {:ok, attendance} = Attendances.create_attendance(attrs)

      attendance
    end

    test "create attendance with valid data", %{valid_attrs: valid_attrs} do
      assert {:ok, %Attendance{} = attendance} = Attendances.create_attendance(valid_attrs)
      assert attendance.email == "@example.com"
    end

    test "new attendance loads an event", %{valid_attrs: valid_attrs} do
      assert {:ok, %Attendance{} = attendance} = Attendances.create_attendance(valid_attrs)
      assert attendance.event.title == "title1"
    end

    test "create attendance with invalid data returns error", %{invalid_attrs: invalid_attrs} do
      assert {:error, %Ecto.Changeset{}} = Attendances.create_attendance(invalid_attrs)
    end

    test "update attendance with valid data", %{
      valid_attrs: valid_attrs,
      update_attrs: update_attrs
    } do
      attendance = attendance_fixture(valid_attrs)

      assert {:ok, %Attendance{} = attendance} =
               Attendances.update_attendance(attendance, update_attrs)

      assert attendance.email == "@example.io"
    end

    test "update attendance with invalid data returns error", %{
      valid_attrs: valid_attrs,
      invalid_attrs: invalid_attrs
    } do
      attendance = attendance_fixture(valid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               Attendances.update_attendance(attendance, invalid_attrs)
    end

    test "delete_attendance/1", %{valid_attrs: valid_attrs} do
      attendance = attendance_fixture(valid_attrs)
      assert {:ok, %Attendance{}} = Attendances.delete_attendance(attendance)
      assert_raise Ecto.NoResultsError, fn -> Attendances.get_attendance!(attendance.id) end
    end

    test "change_attendance/1 returns an attendance changeset", %{valid_attrs: valid_attrs} do
      attendance = attendance_fixture(valid_attrs)
      assert %Ecto.Changeset{} = Attendances.change_attendance(attendance)
    end
  end
end
