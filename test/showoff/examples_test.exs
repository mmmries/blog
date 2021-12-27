defmodule Showoff.ExamplesTest do
  use ExUnit.Case, async: true

  test "examples are a list of parsed drawings" do
    list = Showoff.Examples.list()
    assert is_list(list)
    assert Enum.count(list) > 1
  end
end
