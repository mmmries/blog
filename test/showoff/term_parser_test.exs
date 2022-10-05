defmodule Showoff.TermParserTest do
  use ExUnit.Case, async: true
  import Showoff.TermParser, only: [parse: 1]

  @succesful_examples [
    {"true", true},
    {"false", false},
    {"[]", []},
    {"%{}", %{}},
    {"{:circle, %{cx: 50, cy: 50}, nil}", {:circle, %{cx: 50, cy: 50}, nil}}
  ]

  Enum.each(@succesful_examples, fn {text, term} ->
    @text text
    @term term
    test "can parse #{text}" do
      assert parse(@text) == {:ok, @term}
    end
  end)

  @non_literal_examples [
    "fal",
    "%{\"a\" => a}",
    "IO.puts(nil)"
  ]
  Enum.each(@non_literal_examples, fn text ->
    @text text
    test "cannot parse #{text}" do
      assert parse(@text) == {:error, "string contains non-literal term(s)"}
    end
  end)
end
