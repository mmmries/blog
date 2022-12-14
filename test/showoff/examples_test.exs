defmodule Showoff.ExamplesTest do
  use ExUnit.Case, async: true

  test "examples are a list of parsed drawings" do
    list = Showoff.Examples.list()
    assert is_list(list)
    assert Enum.count(list) > 1
  end

  test "examples can be looked by their 'id'" do
    assert {:ok, drawing} = Showoff.Examples.get("circle")
    assert drawing.text == "' You can draw simple shapes like a circle\n\ncircle"
  end
end
