defmodule BioMonitor.SessionController do
  use BioMonitor.Web, :controller
  import Comeonin.Bcrypt, only: [checkpw: 2]
  alias BioMonitor.User
  alias BioMonitor.Session

  def create(conn, %{"user" => %{ "email" => email, "password" => password}}) do
    with user = Repo.get_by(User, email: email),
      true <- user != nil,
      true <- checkpw(password, user.password_digest),
      session_changeset <- Session.registration_changeset(%Session{}, %{user_id: user.id}),
      {:ok, session} <- Repo.insert(session_changeset)
    do
      conn
      |> put_status(:created)
      |> put_resp_header("access-token", session.token)
      |> render(BioMonitor.UserView, "show.json", user: user)
    else
      nil -> 
        conn 
        |> put_status(:not_found)
        |> render(BioMonitor.ErrorView, "404.json")
      _ -> 
        conn
        |> put_status(:unauthorized)
        |> render(BioMonitor.ErrorView, "401.json")
    end 
  end

  def show(conn, _params) do
    {_, token} = List.keyfind(conn.req_headers, "access-token", 0)
    with session = Repo.get_by(Session, token: token),
      true <- session != nil,
      user <- Repo.preload(session, :user).user,
      true <- user != nil
    do
      conn
      |> put_resp_header("access-token", session.token)
      |> render(BioMonitor.UserView, "show.json", user: user)    
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> render(BioMonitor.ErrorView, "404.json")
      _ ->
        conn
        |> put_status(:unauthorized)
        |> render(BioMonitor.ErrorView, "401.json")
    end  
  end

  def delete(conn, _params) do
    {_, token} = List.keyfind(conn.req_headers, "access-token", 0)
    with session = Repo.get_by(Session, token: token),
      true <- session != nil,
      {:ok, _session} <- Repo.delete session
    do
      conn
        |> put_status(:ok)
        |> render("delete.json", %{})
    else
      false -> 
        conn
        |> put_status(:not_found)
        |> render(BioMonitor.ErrorView, "404.json")
      {:error, _session} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(BioMonitor.ErrorView, "500")
      _ -> 
        conn
        |> put_status(:unauthorized)
        |> render(BioMonitor.ErrorView, "401.json")
    end 
  end
end