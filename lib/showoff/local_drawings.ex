defmodule Showoff.LocalDrawings do
  @moduledoc """
  This represents the local SQlite storage for rooms and drawings

  This module is an internal API and is usually accessed from the `Showoff.RecentDrawings` module.
  """

  import Ecto.Query
  # TODO remove this
  alias Showoff.Drawing
  alias Showoff.{Repo, Room, Sketch}

  def add_drawing(room_name, %Drawing{} = drawing) when is_binary(room_name) do
    room_name
    |> room_name_to_id()
    |> add_drawing(drawing)
  end

  def add_drawing(room_id, %Drawing{} = drawing) when is_integer(room_id) do
    result =
      Sketch.changeset(%{
        room_id: room_id,
        source: drawing.text,
        svg: drawing.svg
      })
      |> Repo.insert()

    case result do
      {:ok, sketch} ->
        publish_updated_list(room_id)
        {:ok, sketch}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def all_room_names do
    from(r in Room, select: r.name) |> Repo.all()
  end

  def delete(_room_name, id) do
    case Repo.get(Sketch, id) do
      nil ->
        :already_deleted

      sketch ->
        Repo.delete!(sketch)
        publish_updated_list(sketch.room_id)
    end
  end

  def list(room_name) when is_binary(room_name) do
    room_name
    |> room_name_to_id()
    |> list()
  end

  def list(room_id) when is_integer(room_id) do
    from(s in Sketch,
      where: s.room_id == ^room_id,
      order_by: [desc: s.id]
    )
    |> Repo.all()
  end

  def room_name_to_id(room_name) do
    case Repo.get_by(Room, name: room_name) do
      nil ->
        room = Repo.insert!(%Room{name: room_name})
        Showoff.RoomRegistry.register(room_name)
        room.id

      %Room{id: room_id} ->
        room_id
    end
  end

  defp publish_updated_list(room_id) do
    BlogWeb.Endpoint.broadcast(
      "recent_drawings:#{room_id}",
      "update",
      %{recent: list(room_id)}
    )
  end
end
