defmodule EventManagerWeb.Schema do
  use Absinthe.Schema

  import_types(EventManagerWeb.Types.CurrentUser)
  import_types(EventManagerWeb.Schema.Events)

  query do
    field :current_user, :current_user do
      resolve(&EventManagerWeb.Resolvers.Users.current_user/2)
    end

    import_fields(:event_queries)
  end

  mutation do
    import_fields(:event_mutations)
  end
end
