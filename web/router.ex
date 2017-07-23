defmodule BioMonitor.Router do
  use BioMonitor.Web, :router
  use ExAdmin.Router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
  end

  scope "/" do
    pipe_through :browser
    coherence_routes()
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BioMonitor do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/admin", ExAdmin do
    pipe_through :protected
    admin_routes()
  end

  scope "/api", BioMonitor do
    pipe_through :api

    post "/sessions/login", SessionController, :create
    get "/sessions/current", SessionController, :show
    delete "/sessions/logout", SessionController, :delete

    resources "/users", UserController, except: [:new, :edit]

    post "/routines/stop", RoutineController, :stop
    post "/routines/start", RoutineController, :start
    resources "/routines", RoutineController, except: [:new, :edit] do
      resources "/readings", ReadingController, only: [:index]
    end
  end
end
