defmodule BlogWeb.MnistLive do
  use Phoenix.LiveView
  require Logger
  alias Ml.Mnist

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Mnist Tester")
      |> assign(:probablity, nil)
      |> assign(:guess, nil)
      |> assign(:mnist, Mnist.load())

    {:ok, socket}
  end

  def handle_event("user_drawing", %{"pixels" => pixels}, socket) do
    preview(pixels)
    mnist = socket.assigns.mnist
    {usec, {probability, guess}} = :timer.tc(fn ->
      Mnist.predict(mnist, pixels)
    end)
    Logger.info("it took #{usec}µsec to make an mnist prediction")
    socket =
      socket
      |> assign(:probability, probability)
      |> assign(:guess, guess)
    {:noreply, socket}
  end

  def preview(pixels) do
    IO.write("\nPREVIEW\n")
    for i <- 0..27 do
      for j <- 0..27 do
        addr = (i * 28) + j
        pixel = case Enum.at(pixels, addr) do
          0 -> " "
          255 -> "#"
          _ -> "o"
        end
        IO.write(pixel)
      end
      IO.write("\n")
    end
    nil
  end
end
