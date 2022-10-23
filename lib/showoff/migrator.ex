defmodule Showoff.Migrator do
  use GenServer

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(nil) do
    Ecto.Migrator.run(Showoff.Repo, :up, all: true) |> IO.inspect(label: "migration")
    {:ok, nil}
  end
end
