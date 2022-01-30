defmodule Showoff.RecentDrawings do
  alias __MODULE__
  alias Showoff.Drawing

  @doc "this function opens the DETS table used to store drawings, it should be called when the application starts"
  def init do
    filename = Showoff.dets_dir()
               |> Path.join("drawings.dets")
               |> String.to_charlist()
    {:ok, _table_name} = :dets.open_file(RecentDrawings, file: filename)
  end

  def add_drawing(room_name, %Drawing{}=drawing) do
    id = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
    true = :dets.insert_new(__MODULE__, {{room_name, id}, drawing})
    publish_updated_list(room_name)
  end

  def delete(room_name, id) do
    :dets.delete(__MODULE__, {room_name, id})
    publish_updated_list(room_name)
  end

  def list(room_name) do
    :dets.match(RecentDrawings, {{room_name, :"$1"}, :"$2"})
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.map(fn([id, drawing]) -> {id, drawing} end)
  end

  defp publish_updated_list(room_name) do
    BlogWeb.Endpoint.broadcast(
      "recent_drawings:#{room_name}",
      "update",
      %{recent: list(room_name)}
    )
  end
end
