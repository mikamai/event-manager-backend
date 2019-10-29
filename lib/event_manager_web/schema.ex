defmodule EventManagerWeb.Schema do
  @moduledoc """
  Public GraphQL schema.
  """

  use Absinthe.Schema

  alias EventManager.{Events, Users}

  import_types(Absinthe.Type.Custom)
  import_types(EventManagerWeb.Types.CurrentUser)
  import_types(EventManagerWeb.Types.User)
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

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Events, Events.data())
      |> Dataloader.add_source(Users, Users.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
