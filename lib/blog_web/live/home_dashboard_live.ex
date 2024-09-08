defmodule BlogWeb.HomeDashboardLive do
  use Phoenix.LiveView

  def mount(_args, session, socket) do
    username = Map.get(session, "current_user")
    socket = assign(socket, :username, username)
    {:ok, socket}
  end
end
