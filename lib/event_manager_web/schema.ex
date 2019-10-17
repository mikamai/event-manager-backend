defmodule EventManagerWeb.Schema do
  use Absinthe.Schema

  import_types(EventManagerWeb.Schema.CurrentUser)
  import_types(EventManagerWeb.Schema.Event)

  query do
    field :current_user, :current_user do
      resolve(&EventManagerWeb.Resolvers.Users.current_user/2)
    end
  end

  mutation do
    import_fields(:event_mutations)
  end
end
