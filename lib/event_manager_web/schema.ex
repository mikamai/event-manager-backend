defmodule EventManagerWeb.Schema do
  use Absinthe.Schema

  import_types(EventManagerWeb.Schema.CurrentUser)

  query do
    field :current_user, :current_user do
      resolve(&EventManagerWeb.Resolvers.Users.current_user/2)
    end
  end
end
