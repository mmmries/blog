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
      deps: deps()
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

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.13"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_view, "~> 0.7"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},

      {:bayesic, "~> 0.1"},
      {:earmark, "~> 1.3"},
      {:floki, "~> 0.25"},
      {:makeup_elixir, "~> 0.14"},
      {:makeup_erlang, "~> 0.1.0"},
      {:stemmer, "~> 1.0"},
      {:toml, "~> 0.6.1"},

      {:phoenix_live_reload, "~> 1.2", only: :dev},
    ]
  end
end
