defmodule EventManagerWeb.Context do
  @behaviour Plug

  import Plug.Conn

  require Logger

  alias EventManager.Users

  def init(opts), do: opts

  def call(conn, _) do
    context =
      build_context(conn)
      |> set_locale()

    Absinthe.Plug.put_options(conn, context: context)
  end

  @doc """
  Return the current user context based on the authorization header
  """
  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- authorize(token) do
      %{current_user: current_user}
    else
      {:error, reason} ->
        Logger.error("Token verification failed: #{inspect(reason)}")
        %{current_user: nil}

      _ ->
        %{current_user: nil}
    end
  end

  defp authorize(token) do
    case OpenIDConnect.verify(:keycloak, token) do
      {:ok, claims} ->
        if DateTime.compare(DateTime.utc_now(), DateTime.from_unix!(claims["exp"])) == :gt do
          {:error, "token expired"}
        else
          params = Users.from_claims(claims)

          result =
            if user = Users.get_user(params.id) do
              Users.update_user(user, params)
            else
              Users.create_user(params)
            end

          case result do
            {:ok, user} -> {:ok, user}
            {:error, changeset} -> {:error, changeset.errors}
          end
        end

      {:error, :verify, reason} ->
        {:error, reason}
    end
  end

  defp set_locale(%{current_user: nil} = context), do: context

  defp set_locale(%{current_user: current_user} = context) do
    Gettext.put_locale(current_user.locale)
    context
  end
end
