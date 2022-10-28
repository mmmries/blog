defmodule Showoff.Migrator do
  use GenServer
  alias __MODULE__
  require Logger

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

    if File.exists?(filename) do
      load_from_dets_and_insert_into_sqlite(filename)
    else
      Logger.info("Showoff.Migrator => already migrated to sqlite!")
    end
  end

  def load_from_dets_and_insert_into_sqlite(filename) do
    {:ok, _table_name} = :dets.open_file(Migrator, file: filename)

    :dets.match(Migrator, {{:"$1", :"$2"}, :"$3"})
    |> Enum.sort()
    |> Enum.each(fn [room_name, id, drawing] ->
      case Showoff.LocalDrawings.add_drawing(room_name, drawing) do
        {:ok, sketch} ->
          Logger.info("migrated #{room_name}.#{id} => #{sketch.id}")
          :ok

        {:error, changeset} ->
          Logger.error("Could not migrate drawing #{room_name}.#{id}: #{err_message(changeset)}")
      end
    end)

    :dets.close(Migrator)
    destination =
      Showoff.dets_dir()
      |> Path.join("_migrated.drawings.dets")

    File.rename!(filename, destination)
  end

  defp err_message(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    |> Map.values()
    |> List.flatten()
    |> Enum.join(", ")
  end
end
