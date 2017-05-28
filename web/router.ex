defmodule BioMonitor.Router do
  use BioMonitor.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BioMonitor do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", BioMonitor do
    pipe_through :api
    post "/sessions/login", SessionController, :create
    get "/sessions/current", SessionController, :show
    delete "/sessions/logout", SessionController, :delete
    resources "/users", UserController, except: [:new, :edit]
  end
end
