defmodule Ml.Mnist do
  require Axon

  @model_file :code.priv_dir(:blog) |> Path.join("mnist/model.bin")
  @state_file :code.priv_dir(:blog) |> Path.join("mnist/model_state.bin")

  defp transform_images({bin, type, shape}) do
    bin
    |> Nx.from_binary(type)
    |> Nx.reshape({elem(shape, 0), 784})
    |> Nx.divide(255.0)
    |> Nx.ceil() # I want to test against simple black-white inputs, so I'm forcing everything to 0.0 or 1.0
    |> Nx.to_batched_list(32)
    # Test split
    |> Enum.split(1750)
  end

  defp transform_labels({bin, type, _}) do
    bin
    |> Nx.from_binary(type)
    |> Nx.new_axis(-1)
    |> Nx.equal(Nx.tensor(Enum.to_list(0..9)))
    |> Nx.to_batched_list(32)
    # Test split
    |> Enum.split(1750)
  end

  defp build_model(input_shape) do
    Axon.input(input_shape)
    |> Axon.dense(128, activation: :relu)
    |> Axon.dropout()
    |> Axon.dense(10, activation: :softmax)
  end

  defp train_model(model, train_images, train_labels, epochs) do
    model
    |> Axon.Loop.trainer(:categorical_cross_entropy, Axon.Optimizers.adamw(0.005))
    |> Axon.Loop.metric(:accuracy, "Accuracy")
    |> Axon.Loop.run(Stream.zip(train_images, train_labels), epochs: epochs, compiler: EXLA)
  end

  defp test_model(model, model_state, test_images, test_labels) do
    model
    |> Axon.Loop.evaluator(model_state)
    |> Axon.Loop.metric(:accuracy, "Accuracy")
    |> Axon.Loop.run(Stream.zip(test_images, test_labels), compiler: EXLA)
  end

  def train do
    {images, labels} = Scidata.MNIST.download()

    {train_images, test_images} = transform_images(images)
    {train_labels, test_labels} = transform_labels(labels)

    model = build_model({nil, 784}) |> IO.inspect()

    IO.write("\n\n Training Model \n\n")

    model_state =
      model
      |> train_model(train_images, train_labels, 5)

    IO.write("\n\n Testing Model \n\n")

    model
    |> test_model(model_state, test_images, test_labels)

    IO.write("\n\n")

    File.write!(@model_file, :erlang.term_to_binary(model))
    File.write!(@state_file, :erlang.term_to_binary(model_state))
  end

  def load do
    {
      @model_file |> File.read!() |> :erlang.binary_to_term(),
      @state_file |> File.read!() |> :erlang.binary_to_term()
    }
  end

  def predict({model, state}, pixels) do
    input =
      pixels
      |> :binary.list_to_bin()
      |> Nx.from_binary({:u, 8})
      |> Nx.divide(255.0)
      |> Nx.reshape({1, 784})

    Axon.predict(model, state, input, compiler: EXLA)
    |> Nx.to_flat_list()
    |> Enum.with_index()
    |> Enum.max()
  end
end
