defmodule Showoff.RoomsPresence do
  use Phoenix.Presence,
    otp_app: :blog,
    pubsub_server: Blog.PubSub
end
