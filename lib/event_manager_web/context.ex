defmodule EventManagerWeb.Context do
  @behaviour Plug

  import Plug.Conn
  import Ecto.Query, only: [where: 2]

  require Logger

  alias EventManager.{Repo, User}

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  @doc """
  Return the current user context based on the authorization header
  """
  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- authorize(token) do
      # Logger.info(inspect(current_user))
      %{current_user: current_user}
    else
      {:error, reason} ->
        Logger.error("Token verification failed: #{reason}")
        %{}

      _ ->
        %{}
    end
  end

  defp authorize(token) do
    case OpenIDConnect.verify(:keycloak, token) do
      {:ok, claims} ->
        if DateTime.compare(DateTime.utc_now(), DateTime.from_unix!(claims["exp"])) == :gt,
          do: {:error, "token expired"},
          else: {:ok, EventManagerWeb.Schema.CurrentUser.from_claims(claims)}

      {:error, :verify, reason} ->
        {:error, reason}
    end
  end
end
