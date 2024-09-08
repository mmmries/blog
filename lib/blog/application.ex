defmodule Blog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Blog.Release.migrate()
    cluster_config = Application.get_env(:libcluster, :topologies)

    children = [
      {Phoenix.PubSub, [name: Blog.PubSub, adapter: Phoenix.PubSub.PG2]},
      Showoff.Repo,
      # Start the endpoint when the application starts
      BlogWeb.Endpoint,
      {Blog.SearchServer, nil},
      # Keep track of which servers are hosting which rooms
      Showoff.RoomsPresence,
      Showoff.RoomRegistry
    ]

    children = maybe_prepend_nats_connection(children)

    children =
      if cluster_config do
        child = {Cluster.Supervisor, [cluster_config, [name: Blog.ClusterSupervisor]]}
        [child | children]
      else
        children
      end

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

  defp maybe_prepend_nats_connection(children) do
    if System.get_env("NATS_JWT") do
      [{Gnat.ConnectionSupervisor, nats_connection_settings()} | children]
    else
      children
    end
  end

  defp nats_connection_settings do
    %{
      name: :gnat,
      backoff_period: 5_000,
      connection_settings: [
        %{
          host: "connect.ngs.global",
          tls: true,
          ssl_opts: [verify: :verify_none],
          jwt: System.get_env("NATS_JWT"),
          nkey_seed: System.get_env("NATS_NKEY_SEED")
        }
      ]
    }
  end
end
