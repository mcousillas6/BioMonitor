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
        |> render("error.json")
      true ->
        dummy_checkpw()
        conn
        |> put_status(:unauthorized)
        |> render("error.json")
    end
  end

  def show(conn, _params) do
    token = conn.req_headers["access-token"]
    session = Repo.get_by(Session, token: token)
    cond do
      session -> 
        user = Repo.get(User, session.user_id)
        cond do
          user -> 
            conn
            |> put_resp_header("access-token", session.token)
            |> render(BioMonitor.UserView, "show.json", user: user)
          true -> 
            conn 
            |> put_status(:not_found)
            |> render(BioMonitor.ChangesetView, "error.json")
        end
      true -> 
        conn
        |> put_status(:unauthorized)
        |> render(BioMonitor.ChangesetView, "error.json")
    end
  end

  def delete(conn, _params) do
    token = conn.req_headers["access-token"]
    session = Repo.get_by(Session, token: token) 
    cond do
      session -> 
        user = Repo.get(User, session.user_id)
        cond do
          user -> 
            Repo.delete! user
            conn
            |> put_status(:success)
            |> render("delete.json", user: user)
          true -> 
            conn 
            |> put_status(:not_found)
            |> render(BioMonitor.ChangesetView, "error.json")
        end
      true -> 
        conn
        |> put_status(:unauthorized)
        |> render(BioMonitor.ChangesetView, "error.json")
    end
  end
end