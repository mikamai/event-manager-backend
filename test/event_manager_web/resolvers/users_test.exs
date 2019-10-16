defmodule EventManagerWeb.Resolvers.UsersTest do
  use ExUnit.Case

  alias EventManagerWeb.Resolvers.Users

  describe "current_user" do
    test "returns the current user from the context" do
      assert {:ok, "test"} = Users.current_user(%{}, %{context: %{current_user: "test"}})
    end

    test "returns nil if not present" do
      assert {:ok, nil} = Users.current_user(%{}, %{context: %{}})
    end
  end
end
