defmodule Showoff.RecentDrawings do
  @moduledoc """
  Module to interact with drawings across the cluster

  This module handles finding where a room is being hosted
  in the cluster and then using the LocalDrawings on that
  host.
  """

  alias Showoff.{LocalDrawings, RoomRegistry}

  def add_drawing(room_name, drawing) do
    proxy(room_name, LocalDrawings, :add_drawing, [room_name, drawing])
  end

  def delete(room_name, id) do
    proxy(room_name, LocalDrawings, :delete, [room_name, id])
  end

  def get(room_name, id) do
    proxy(room_name, LocalDrawings, :get, [room_name, id])
  end

  def list(room_name) do
    proxy(room_name, LocalDrawings, :list, [room_name])
  end

  def room_id(room_name) do
    proxy(room_name, LocalDrawings, :room_name_to_id, [room_name])
  end

  defp lookup_node(room_name) do
    case RoomRegistry.lookup_name(room_name) do
      [] -> Node.self()
      [node] -> node
    end
  end

  @timeout 5_000
  defp proxy(room_name, module, fun, args) do
    node = lookup_node(room_name)
    :erpc.call(node, module, fun, args, @timeout)
  end
end
