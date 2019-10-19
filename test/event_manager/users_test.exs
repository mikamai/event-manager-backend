defmodule EventManager.UsersTest do
  use EventManager.DataCase

  alias EventManager.Users

  describe "users" do
    alias EventManager.Events.Event
    alias EventManager.Users.User

    @valid_attrs %{
      id: Ecto.UUID.generate(),
      email: "user@example.com",
      name: "Fake User",
      username: "user",
      first_name: "Fake",
      last_name: "User"
    }

    @update_attrs %{
      username: "new-user"
    }

    @invalid_attrs %{
      email: 1,
      name: nil
    }

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_attrs)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Users.update_user(user, @update_attrs)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end

    test "from_claims/1 returns user params from OIDC claims" do
      claims = %{
        "sub" => Ecto.UUID.generate(),
        "email" => "email@example.com",
        "name" => "Test User",
        "given_name" => "Test",
        "family_name" => "User",
        "preferred_username" => "test",
        "locale" => "fr"
      }

      assert %{
               id: id,
               email: email,
               name: name,
               first_name: first_name,
               last_name: last_name,
               username: username,
               locale: locale
             } = Users.from_claims(claims)

      assert id == claims["sub"]
      assert email == claims["email"]
      assert name == claims["name"]
      assert first_name == claims["given_name"]
      assert last_name == claims["family_name"]
      assert username == claims["preferred_username"]
      assert locale == claims["locale"]
    end

    test "get_created_event/2 returns a specific event created by the user" do
      user = user_fixture()

      event = %Event{
        description: "Test",
        title: "test",
        location: "here",
        public: true,
        start_time: DateTime.utc_now() |> DateTime.truncate(:second),
        end_time: DateTime.utc_now() |> DateTime.truncate(:second)
      }

      event =
        EventManager.Events.change_event(event)
        |> Ecto.Changeset.put_assoc(:creator, user)
        |> EventManager.Repo.insert!()

      assert %Event{id: id} = Users.get_created_event(user, event.id)
      assert id == event.id
    end
  end
end
