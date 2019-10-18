defmodule EventManagerWeb.Types.CurrentUser do
  use Absinthe.Schema.Notation

  import_types(EventManagerWeb.Types.User)

  object :current_user do
    import_fields(:user)
    field :id, non_null(:id)
    field :email, non_null(:string)
  end
end
