defmodule Showoff.LocalDrawings do
  @moduledoc """
  This represents the local DETS storage for rooms and drawings

  This module is an internal API and is usually accessed from the `Showoff.RecentDrawings` module.
  """

  alias __MODULE__
  alias Showoff.Drawing

  @doc "this function opens the DETS table used to store drawings, it should be called when the application starts"
  def init do
    filename = Showoff.dets_dir()
               |> Path.join("drawings.dets")
               |> String.to_charlist()
    {:ok, _table_name} = :dets.open_file(LocalDrawings, file: filename)
  end

  def add_drawing(room_name, %Drawing{}=drawing) do
    id = DateTime.utc_now() |> DateTime.to_unix(:millisecond)
    true = :dets.insert_new(__MODULE__, {{room_name, id}, drawing})
    publish_updated_list(room_name)
  end

  def all_room_names do
    :dets.match(LocalDrawings, {{:"$1", :_}, :_})
    |> Enum.map(&hd/1)
    |> Enum.into(MapSet.new())
  end

  def delete(room_name, id) do
    :dets.delete(__MODULE__, {room_name, id})
    publish_updated_list(room_name)
  end

  def list(room_name) do
    :dets.match(LocalDrawings, {{room_name, :"$1"}, :"$2"})
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.map(fn([id, drawing]) -> {id, drawing} end)
  end

  defp publish_updated_list(room_name) do
    Showoff.RoomRegistry.register(room_name)
    BlogWeb.Endpoint.broadcast(
      "recent_drawings:#{room_name}",
      "update",
      %{recent: list(room_name)}
    )
  end
end
