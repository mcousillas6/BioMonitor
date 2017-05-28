defmodule BioMonitor.SessionController do
  use BioMonitor.Web, :controller
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias BioMonitor.User
  alias BioMonitor.Session

  def create(conn, %{"user" => %{ "email" => email, "password" => password}}) do
    user = Repo.get_by(User, email: email)
    cond do
      user && checkpw(password, user.password_digest) ->
        session_changeset = Session.registration_changeset(%Session{}, %{user_id: user.id})
        {:ok, session} = Repo.insert(session_changeset)
        conn
        |> put_status(:created)
        |> put_resp_header("access-token", session.token)
        |> render(BioMonitor.UserView, "show.json", user: user)
      user ->
        conn
        |> put_status(:unauthorized)
        |> render("401.json")
      true ->
        dummy_checkpw()
        conn
        |> put_status(:unauthorized)
        |> render("401.json")
    end
  end

  def show(conn, _params) do
    {_, token} = List.keyfind(conn.req_headers, "access-token", 0)
    session = Repo.get_by(Session, token: token)
    cond do
      token ->
        cond do
          session ->
              Repo.preload(session, :user)
              conn
              |> put_resp_header("access-token", session.token)
              |> render(BioMonitor.UserView, "show.json", user: session.user)
          true -> 
            conn
            |> put_status(:unauthorized)
            |> render(BioMonitor.ErrorView, "401.json")
        end
      true ->
        conn
        |> put_status(:unauthorized)
        |> render(BioMonitor.ErrorView, "401.json")
    end 
  end

  def delete(conn, _params) do
    {_, token} = List.keyfind(conn.req_headers, "access-token", 0)
    session = Repo.get_by(Session, token: token)
    cond do
      token ->
        cond do
          session -> 
              Repo.delete! session
              conn
              |> put_status(:ok)
              |> render("delete.json")
          true -> 
            conn
            |> put_status(:unauthorized)
            |> render(BioMonitor.ErrorView, "401.json")
        end
      true ->
        conn
        |> put_status(:unauthorized)
        |> render(BioMonitor.ErrorView, "401.json")
    end 
  end
end