defmodule BlogWeb.HomeDashboardLive do
  use Phoenix.LiveView,
    layout: {BlogWeb.Layouts, :home}

  use BlogWeb, :html_helpers

  def mount(_args, session, socket) do
    username = Map.get(session, "current_user")

    socket =
      socket
      |> assign(:username, username)
      |> assign(:authorized?, authorized?(username))

    {:ok, socket}
  end

  def handle_event("garage_door", _atrs, socket) do
    case Home.GarageDoor.toggle() do
      :ok ->
        {:noreply, put_flash(socket, :info, "Pressed")}

      {:error, msg} ->
        {:noreply, put_flash(socket, :error, msg)}
    end
  end

  defp authorized?(username) do
    username in Application.get_env(:blog, :authorized_users)
  end
end
