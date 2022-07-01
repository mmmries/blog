defmodule Showoff.RoomRegistry do
  use GenServer
  alias Showoff.{RoomsPresence, RecentDrawings}

  def register(name) do
    GenServer.call(__MODULE__, {:register, name})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(nil) do
    RecentDrawings.all_room_names()
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
    RoomsPresence.track(self(), "rooms", name, %{node: Node.self()})
  end
end
