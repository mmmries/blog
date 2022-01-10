defmodule BlogWeb.Router do
  use BlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_live_flash
  end

  pipeline :showoff do
    plug :put_root_layout, {BlogWeb.LayoutView, :root}
  end

  scope host: "showoff.", alias: BlogWeb do
    pipe_through [:browser, :showoff]

    get "/", ShowoffController, :index
    live "/rooms/:room_name", ShowoffLive
  end

  scope "/", BlogWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/about/", PageController, :about
    get "/tags/:name", PageController, :tag
    get "/:year/:month/:day/:slug", PageController, :post

    live_session :default, root_layout: {BlogWeb.LayoutView, :root} do
      live "/mnist", MnistLive
    end
  end
end
