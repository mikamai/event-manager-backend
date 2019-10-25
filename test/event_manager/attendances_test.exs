defmodule EventManager.AttendancesTest do
  use EventManager.DataCase

  alias EventManager.Attendances

  describe "attendances" do
    alias EventManager.Attendances.Attendance

    @valid_attrs %{email: "some email"}
    @update_attrs %{email: "some updated email"}
    @invalid_attrs %{email: nil}

    def attendance_fixture(attrs \\ %{}) do
      {:ok, attendance} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Attendances.create_attendance()

      attendance
    end

    test "list_attendances/0 returns all attendances" do
      attendance = attendance_fixture()
      assert Attendances.list_attendances() == [attendance]
    end

    test "get_attendance!/1 returns the attendance with given id" do
      attendance = attendance_fixture()
      assert Attendances.get_attendance!(attendance.id) == attendance
    end

    test "create_attendance/1 with valid data creates a attendance" do
      assert {:ok, %Attendance{} = attendance} = Attendances.create_attendance(@valid_attrs)
      assert attendance.email == "some email"
    end

    test "create_attendance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Attendances.create_attendance(@invalid_attrs)
    end

    test "update_attendance/2 with valid data updates the attendance" do
      attendance = attendance_fixture()

      assert {:ok, %Attendance{} = attendance} =
               Attendances.update_attendance(attendance, @update_attrs)

      assert attendance.email == "some updated email"
    end

    test "update_attendance/2 with invalid data returns error changeset" do
      attendance = attendance_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Attendances.update_attendance(attendance, @invalid_attrs)

      assert attendance == Attendances.get_attendance!(attendance.id)
    end

    test "delete_attendance/1 deletes the attendance" do
      attendance = attendance_fixture()
      assert {:ok, %Attendance{}} = Attendances.delete_attendance(attendance)
      assert_raise Ecto.NoResultsError, fn -> Attendances.get_attendance!(attendance.id) end
    end

    test "change_attendance/1 returns a attendance changeset" do
      attendance = attendance_fixture()
      assert %Ecto.Changeset{} = Attendances.change_attendance(attendance)
    end
  end
end
