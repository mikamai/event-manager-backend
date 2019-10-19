defmodule EventManagerWeb.Types.CurrentUser do
  use Absinthe.Schema.Notation

  object :current_user do
    field :id, non_null(:id)
    field :email, non_null(:string)
    field :name, non_null(:string)
    field :username, non_null(:string)
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
  end
end
