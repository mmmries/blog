defmodule BlogWeb.Router do
  use BlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :put_root_layout, {BlogWeb.Layouts, :root}
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_live_flash
  end

  pipeline :responsive do
    plug :accepts, ["html"]
    plug :put_root_layout, {BlogWeb.Layouts, :responsive}
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_live_flash
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  ## Health Check Routes

  scope "/", BlogWeb do
    pipe_through :api
    
    get "/health", HealthController, :check
  end

  ## Showoff Routes

  scope host: "showoff.", alias: BlogWeb do
    pipe_through :browser

    get "/", ShowoffController, :index
    live "/rooms/:room_name", ShowoffLive
    get "/img/:room_name/:id", ShowoffController, :img
  end

  ## Home App Routes

  scope "/", BlogWeb do
    pipe_through :responsive

    live "/home", HomeDashboardLive

    # OAuth Login
    get "/logout", AuthController, :logout
    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
    post "/auth/:provider/callback", AuthController, :callback
  end

  scope "/", BlogWeb do
    pipe_through :browser

    get "/privacy", PageController, :privacy
    get "/terms", PageController, :terms
  end

  ## Blog Routes

  scope "/", BlogWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/about/", PageController, :about
    get "/tags/:name", PageController, :tag
    get "/:year/:month/:day/:slug", PageController, :post
  end
end
