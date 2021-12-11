defmodule Showoff.KidParserTest do
  use ExUnit.Case, async: true
  import Showoff.KidParser, only: [parse: 1]

  test "parsing a circle" do
    assert parse("circle") == {:ok, [{:circle, %{cx: 50, cy: 50, fill: "black"}, nil}]}
  end
end
