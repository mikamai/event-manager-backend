defmodule EventManagerWeb.Types.User do
  use Absinthe.Schema.Notation

  object :user do
    field :name, non_null(:string)
    field :username, non_null(:string)
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
  end
end
