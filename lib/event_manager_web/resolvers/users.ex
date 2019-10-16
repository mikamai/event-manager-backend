defmodule EventManagerWeb.Resolvers.Users do
  def current_user(_, %{context: %{current_user: current_user}}), do: {:ok, current_user}

  def current_user(_, _), do: {:ok, nil}
end
