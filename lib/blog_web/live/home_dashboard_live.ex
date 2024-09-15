defmodule BlogWeb.HomeDashboardLive do
  use Phoenix.LiveView,
    layout: {BlogWeb.Layouts, :home}

  use BlogWeb, :html_helpers

  require Logger

  @status_topic "home.garage_door.status"

  def mount(_args, session, socket) do
    username = Map.get(session, "current_user")

    socket =
      socket
      |> assign(:username, username)
      |> assign(:garage_door_status, "pending")
      |> assign(:authorized?, authorized?(username))

    if connected?(socket) do
      Task.async(fn -> Home.GarageDoor.get_status() end)
      Gnat.sub(:gnat, self(), @status_topic)
    end

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

  # Get task results
  def handle_info({ref, {:garage_door_status, status}}, socket) do
    Process.demonitor(ref, [:flush])
    {:noreply, assign(socket, garage_door_status: status)}
  end

  def handle_info({ref, {:error, reason}}, socket) do
    Process.demonitor(ref, [:flush])
    {:noreply, put_flash(socket, :error, "#{inspect(reason)}")}
  end

  def handle_info({:DOWN, _ref, :process, _pid, reason}, socket) do
    Logger.error("Async task failed: #{inspect(reason)}")
    {:noreply, put_flash(socket, :error, "Failed to get door status: #{inspect(reason)}")}
  end

  # Subscription updates
  def handle_info({:msg, %{topic: @status_topic, body: status}}, socket) do
    {:noreply, assign(socket, garage_door_status: status)}
  end

  defp authorized?(username) do
    username in Application.get_env(:blog, :authorized_users)
  end
end
