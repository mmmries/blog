defmodule Blog.MixProject do
  use Mix.Project

  def project do
    [
      app: :blog,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: releases()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Blog.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp aliases do
    [
      "assets.deploy": ["esbuild default --minify", "tailwind default --minify", "phx.digest"]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 3.1"},
      {:phoenix_live_view, "~> 0.16"},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:bayesic, "~> 0.1"},
      {:chunky_svg, "~> 0.2"},
      {:earmark, "~> 1.3"},
      {:floki, "~> 0.25"},
      {:libcluster, "~> 3.3"},
      {:makeup_elixir, "~> 0.14"},
      {:makeup_erlang, "~> 0.1.0"},
      {:nimble_parsec, "~> 1.2"},
      {:stemmer, "~> 1.0"},
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
      {:toml, "~> 0.6.1"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:phoenix_live_reload, "~> 1.2", only: :dev}
    ]
  end

  defp releases do
    [
      blog: [
        include_executables_for: [:unix],
        cookie: "7HdDx0YmOdv6YyBo_4UXC7n7vb5LiHTP13iXWh7GMjCUuM8apX9q7Q=="
      ]
    ]
  end
end
