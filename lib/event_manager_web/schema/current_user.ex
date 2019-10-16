defmodule EventManagerWeb.Schema.CurrentUser do
  use Absinthe.Schema.Notation

  object :current_user do
    field :id, non_null(:id)
    field :email, non_null(:string)
    field :name, non_null(:string)
    field :username, non_null(:string)
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
  end

  def from_claims(claims) do
    Map.new(claims, fn {k, v} -> {String.to_atom(k), v} end)
    |> Map.put(:id, claims["sub"])
    |> Map.put(:first_name, claims["given_name"])
    |> Map.put(:last_name, claims["family_name"])
    |> Map.put(:username, claims["preferred_username"])
  end
end
