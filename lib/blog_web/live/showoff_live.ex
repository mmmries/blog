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
      |> assign(:page_title, "Showoff | #{room_name}")
      |> assign(:drawing_text, "")
      |> assign(:err, "")
      |> assign(:recent_ids, RecentDrawings.list(room_name))
      |> assign(:svg, nil)
      |> assign(:alt, false)

    {:ok, socket}
  end

  def handle_event("draw", %{"drawing_text" => text}, socket) do
    socket = socket |> update_drawing(text) |> assign(:drawing_text, text)
    {:noreply, socket}
  end

  def handle_event("example", %{"id" => id}, socket) do
    {:ok, drawing} = Showoff.Examples.get(id)
    socket = socket |> update_drawing(drawing.text) |> assign(:drawing_text, drawing.text)
    {:noreply, socket}
  end

  def handle_event("sketch", %{"id" => id}, %{assigns: %{alt: true}} = socket) do
    id = String.to_integer(id)
    RecentDrawings.delete(socket.assigns.room_name, id)
    {:noreply, socket}
  end

  def handle_event("sketch", %{"id" => id}, socket) do
    id = String.to_integer(id)
    sketch = RecentDrawings.get(socket.assigns.room_name, id)
    socket = assign(socket, %{err: nil, svg: sketch.svg, drawing_text: sketch.source})
    {:noreply, socket}
  end

  def handle_event("publish", %{"drawing_text" => text}, socket) do
    room_name = socket.assigns.room_name

    case Showoff.kid_text_to_drawing(text, "anonymous") do
      {:ok, drawing} ->
        case RecentDrawings.add_drawing(room_name, drawing) do
          {:ok, _} ->
            {:noreply, assign(socket, :err, "")}

          {:error, changeset} ->
            {:noreply, assign(socket, :err, err_message(changeset))}
        end

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
    socket = assign(socket, :recent_ids, recent)
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

  defp err_message(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    |> Map.values()
    |> List.flatten()
    |> Enum.join(", ")
  end
end
