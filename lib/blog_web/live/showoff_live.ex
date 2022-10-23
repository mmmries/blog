defmodule BlogWeb.ShowoffLive do
  use Phoenix.LiveView
  alias Showoff.RecentDrawings

  def mount(%{"room_name" => room_name}, _session, socket) do
    room_id = RecentDrawings.room_id(room_name)
    :ok = BlogWeb.Endpoint.subscribe("recent_drawings:#{room_id}")

    socket =
      socket
      |> update_drawing("")
      |> assign(:room_name, room_name)
      |> assign(:room_id, room_id)
      |> assign(:drawing_text, "")
      |> assign(:err, "")
      |> assign(:recent, RecentDrawings.list(room_id))
      |> assign(:svg, nil)
      |> assign(:alt, false)

    {:ok, socket}
  end

  def handle_event("draw", %{"drawing_text" => text}, socket) do
    socket = socket |> update_drawing(text) |> assign(:drawing_text, text)
    {:noreply, socket}
  end

  def handle_event("example", %{"id" => id}, %{assigns: %{alt: true}} = socket) do
    id = String.to_integer(id)
    RecentDrawings.delete(socket.assigns.room_name, id)
    {:noreply, socket}
  end

  def handle_event("example", %{"text" => text}, socket) do
    socket = socket |> update_drawing(text) |> assign(:drawing_text, text)
    {:noreply, socket}
  end

  def handle_event("publish", %{"drawing_text" => text}, socket) do
    room_name = socket.assigns.room_name

    case Showoff.kid_text_to_drawing(text, "anonymous") do
      {:ok, drawing} ->
        RecentDrawings.add_drawing(room_name, drawing)
        {:noreply, assign(socket, :err, "")}

      {:error, _err} ->
        socket =
          socket
          |> assign(:err, "an error occured trying to draw that")
          |> assign(:drawing_text, text)

        {:noreply, socket}
    end
  end

  def handle_event("keydown", %{"key" => "Alt"}, socket) do
    socket = assign(socket, :alt, true)
    {:noreply, socket}
  end

  def handle_event("keyup", %{"key" => "Alt"}, socket) do
    socket = assign(socket, :alt, false)
    {:noreply, socket}
  end

  def handle_info(%{event: "update", payload: %{recent: recent}}, socket) do
    socket = assign(socket, :recent, recent)
    {:noreply, socket}
  end

  defp update_drawing(socket, text) do
    case Showoff.kid_text_to_svg(text) do
      {:ok, svg} ->
        assign(socket, :svg, svg)

      {:error, _err} ->
        assign(socket, :svg, nil)
    end
  end
end
