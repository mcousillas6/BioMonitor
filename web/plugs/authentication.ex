defmodule BioMonitor.Authentication do
  import Plug.Conn
  import Ecto.Query, only: [from: 2]
  alias BioMonitor.{Repo, User, Session}
  
  def init(options), do: options

  def call(conn, _opts) do
    case find_user(conn) do
      {:ok, user} -> assign(conn, :current_user, user)
      {:error, msg} -> auth_error!(conn, msg)
    end
  end

  defp find_user(conn) do
    with token = get_req_header(conn, "access-token"),
      {:ok, session} <- find_session_by_token(token),
    do: find_user_by_session(session)
  end

  defp find_session_by_token([token]) do
    case Repo.one(from s in Session, where: s.token == ^token) do
      nil -> {:error, "No session"}
      session -> {:ok, session}
    end
  end

  defp find_session_by_token(_otherwise), do: {:error, "No token"}

  defp find_user_by_session(session) do
    case Repo.get(User, session.user_id) do
      nil -> {:error, "No user for that session"}
      user -> {:ok, user}
    end
  end

  defp auth_error!(conn, msg) do
    conn 
    |> send_resp(:unauthorized, Poison.encode!(%{error: "Invalid token", message: msg}))
    |> halt() 
  end
end
