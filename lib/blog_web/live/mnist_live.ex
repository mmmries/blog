defmodule BlogWeb.MnistLive do
  use Phoenix.LiveView
  require Logger

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Mnist Tester")
      |> assign(:probablity, nil)
      |> assign(:guess, nil)

    {:ok, socket}
  end

  def handle_event("user_drawing", %{"pixels" => pixels}, socket) do
    {usec, {probability, guess}} = :timer.tc(fn ->
      Ml.MnistServer.predict(pixels)
    end)
    Logger.info("it took #{usec}µsec to make an mnist prediction")
    socket =
      socket
      |> assign(:probability, probability)
      |> assign(:guess, guess)
    {:noreply, socket}
  end
end
