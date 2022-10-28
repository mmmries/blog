defmodule Showoff.LocalDrawingsTest do
  use Showoff.RepoCase
  alias Showoff.LocalDrawings

  test "you can add a drawing" do
    {:ok, drawing} = Showoff.kid_text_to_drawing("circle", "anonymous")
    LocalDrawings.add_drawing("room", drawing)

    assert "room" in LocalDrawings.all_room_names()
    assert [d1] = LocalDrawings.list("room")
    assert d1.source == "circle"
  end

  test "duplicate drawings are rejected" do
    {:ok, drawing} = Showoff.kid_text_to_drawing("circle", "anonymous")
    assert {:ok, _sketch} = LocalDrawings.add_drawing("room", drawing)

    assert {:error, changeset} = LocalDrawings.add_drawing("room", drawing)
    refute changeset.valid?
  end
end
