defmodule Ml.MnistServer do
  use GenServer
  require Logger

  def predict(pixels) do
    GenServer.call(__MODULE__, {:predict, pixels})
  end

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    {:ok, nil, {:continue, :build_model}}
  end

  def handle_continue(:build_model, nil) do
    Logger.info("Training mnist model")
    {model, state} = Ml.Mnist.train()
    Logger.info("Finished training mnist model")
    {:noreply, {model, state}}
  end

  def handle_call({:predict, pixels}, _from, {model, state}) do
    prediction = Ml.Mnist.predict(model, state, pixels)
    {:reply, prediction, {model, state}}
  end
end
