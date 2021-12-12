defmodule Showoff.KidParserTest do
  use ExUnit.Case, async: true
  import Showoff.KidParser, only: [parse: 1]

  describe "svg shapes" do
    test "parsing a rect" do
      assert parse("rect") == {:ok, [{"rect", %{}, nil}]}
    end

    test "with attributes" do
      assert parse("rect x=10 y=10") == {:ok, [{"rect", %{"x" => 10, "y" => 10}, nil}]}
    end
  end

  describe "special shapes" do
    test "parsing a triangle" do
      assert parse("triangle") == {:ok, [{:triangle, %{cx: 50, cy: 50, fill: "black", r: 25}}]}
    end

    test "triangle with attributes" do
      assert parse("triangle fill=red   foo=bar\n") == {:ok, [
        {:triangle, %{:cx => 50, :cy => 50, :fill => "red", :r => 25, "foo" => "bar"}}
      ]}
    end

    test "parsing multiple shapes" do
      assert parse("pentagon cx=25\r\nsquare\r\nhexagon") == {:ok, [
        {:pentagon, %{cx: 25, cy: 50, fill: "black", r: 25}},
        {:square, %{cx: 50, cy: 50, fill: "black", r: 25}},
        {:hexagon, %{cx: 50, cy: 50, fill: "black", r: 25}}
      ]}
    end

    test "shapes separated by multiple newlines" do
      assert parse("octagon\n\n\r\noctagon") == {:ok, [
        {:octagon, %{cx: 50, cy: 50, fill: "black", r: 25}},
        {:octagon, %{cx: 50, cy: 50, fill: "black", r: 25}}
      ]}
    end
  end

  test "invalid syntax" do
    assert {:error, _message, _str, _, _, _} = parse("_-+/*#%&(*&")
  end
end
