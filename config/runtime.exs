import Config

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  # IMPORTANT: Get the app_name we're using
  app_name =
    System.get_env("FLY_APP_NAME") ||
      raise "FLY_APP_NAME not available"

  config :blog, BlogWeb.Endpoint,
    # IMPORTANT: tell our app about the host name to use when generating URLs
    url: [host: "#{app_name}.fly.dev", port: 80],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: secret_key_base

  # IMPORTANT: Enable the endpoint for releases
  config :hello_elixir, HelloElixirWeb.Endpoint, server: true
end
