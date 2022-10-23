defmodule Blog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Showoff.LocalDrawings.init()

    cluster_config = Application.get_env(:libcluster, :topologies)

    children = [
      {Cluster.Supervisor, [cluster_config, [name: Blog.ClusterSupervisor]]},
      {Phoenix.PubSub, [name: Blog.PubSub, adapter: Phoenix.PubSub.PG2]},
      Showoff.Repo,
      {Showoff.Migrator, nil},
      # Start the endpoint when the application starts
      BlogWeb.Endpoint,
      {Blog.SearchServer, nil},
      # Keep track of which servers are hosting which rooms
      Showoff.RoomsPresence,
      Showoff.RoomRegistry
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BlogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
