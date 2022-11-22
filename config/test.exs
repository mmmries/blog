import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :blog, BlogWeb.Endpoint,
  http: [port: 4002],
  server: false

path = Path.join([__DIR__, "..", "tmp", "sketches_test.sqlite3"])

config :blog, Showoff.Repo, database: path

config :libcluster, topologies: nil

# Print only warnings and errors during test
config :logger, level: :warning
