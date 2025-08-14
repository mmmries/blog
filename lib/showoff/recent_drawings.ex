defmodule Showoff.RecentDrawings do
  @moduledoc """
  Module to interact with drawings in single-node mode

  This module provides a simplified interface to LocalDrawings
  for single-node deployment.
  """

  alias Showoff.LocalDrawings

  def add_drawing(room_name, drawing) do
    LocalDrawings.add_drawing(room_name, drawing)
  end

  def delete(room_name, id) do
    LocalDrawings.delete(room_name, id)
  end

  def get(room_name, id) do
    LocalDrawings.get(room_name, id)
  end

  def list(room_name) do
    LocalDrawings.list(room_name)
  end

  def room_id(room_name) do
    LocalDrawings.room_name_to_id(room_name)
  end
end
