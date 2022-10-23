defmodule Showoff.Migrator do
  use GenServer

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(nil) do
    Ecto.Migrator.run(Showoff.Repo, :up, all: true)
    {:ok, nil}
  end

  def migrate_from_dets_to_ecto do
    filename =
      Showoff.dets_dir()
      |> Path.join("drawings.dets")
      |> String.to_charlist()

    {:ok, _table_name} = :dets.open_file(LocalDrawings, file: filename)
  end
end
