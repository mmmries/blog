defmodule BlogWeb.HomeDashboardLive do
  use Phoenix.LiveView

  def mount(_args, session, socket) do
    username = Map.get(session, "current_user")

    socket =
      socket
      |> assign(:username, username)
      |> assign(:authorized?, authorized?(username))

    {:ok, socket}
  end

  defp authorized?(username) do
    username in Application.get_env(:blog, :authorized_users)
  end
end
