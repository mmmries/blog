defmodule BlogWeb.MnistLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket =
      socket |> assign(:page_title, "Mnist Tester")

    {:ok, socket}
  end

  def handle_event("user_drawing", %{"pixels" => pixels}, socket) do
    IO.inspect(pixels, label: "pixels")
    {:noreply, socket}
  end
end
