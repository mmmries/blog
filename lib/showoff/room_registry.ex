defmodule Showoff.RoomRegistry do
  use GenServer
  alias Showoff.{RoomsPresence, LocalDrawings}
  @topic "rooms"

  @spec lookup_name(String.t()) :: list(node())
  def lookup_name(name) do
    case RoomsPresence.get_by_key(@topic, name) do
      [] -> []
      %{metas: metas} ->
        Enum.map(metas, & &1.node)
    end
  end

  def register(name) do
    GenServer.call(__MODULE__, {:register, name})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(nil) do
    LocalDrawings.all_room_names()
    |> Enum.each(fn name ->
      {:ok, _} = track_presence(name)
    end)

    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:register, name}, _from, state) do
    track_presence(name)
    {:reply, :ok, state}
  end

  defp track_presence(name) do
    RoomsPresence.track(self(), @topic, name, %{node: Node.self()})
  end
end
