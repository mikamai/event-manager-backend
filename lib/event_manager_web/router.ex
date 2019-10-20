defmodule EventManagerWeb.Router do
  use EventManagerWeb, :router

  pipeline :graphql do
    use Plug.ErrorHandler
    use Sentry.Plug
    plug :accepts, ["json"]
    plug EventManagerWeb.Context
  end

  scope "/graphql" do
    pipe_through :graphql

    forward "/explorer", Absinthe.Plug.GraphiQL,
      schema: EventManagerWeb.Schema,
      socket: EventManagerWeb.UserSocket,
      interface: :playground

    forward "/", Absinthe.Plug, schema: EventManagerWeb.Schema
  end
end
