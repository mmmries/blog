defmodule Blog.SearchServer do
  use GenServer
  require Logger

  def query(string) do
    GenServer.call(__MODULE__, {:query, string})
  end

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    {:ok, nil, {:continue, :build_index}}
  end

  def handle_continue(:build_index, _state) do
    {micros, index} =
      :timer.tc(fn ->
        Blog.Search.build_index(Blog.list_posts())
      end)

    Logger.info("it took #{micros}µs to build the text index")
    {:noreply, index}
  end

  def handle_call({:query, query}, _from, index) do
    {micros, response} =
      :timer.tc(fn ->
        Blog.Search.search(index, query)
      end)

    Logger.info("it took #{micros}µs to query")
    {:reply, response, index}
  end
end
