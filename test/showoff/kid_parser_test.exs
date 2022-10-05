defmodule Showoff.KidParserTest do
  use ExUnit.Case, async: true
  import Showoff.KidParser, only: [parse: 1]

  describe "comments" do
    test "just a single comment" do
      assert parse("' This is a comment") == {:ok, []}
    end

    test "comments before a shape" do
      assert parse("'This is a rectangle\r\n\nrect") == {:ok, [{"rect", %{}, nil}]}
    end
  end

  describe "svg shapes" do
    test "parsing a rect" do
      assert parse("rect") == {:ok, [{"rect", %{}, nil}]}
    end

    test "with attributes" do
      assert parse("rect x=10 y=10") == {:ok, [{"rect", %{"x" => 10, "y" => 10}, nil}]}
    end

    test "parsing attributes with complex values" do
      assert parse("g transform=rotate(180,50,50)") == {:ok, [
        {"g", %{"transform" => "rotate(180,50,50)"}, nil}
      ]}
    end

    test "parsing attributes that start with an integer" do
      assert parse("animate dur=10s") == {:ok, [
        {"animate", %{"dur" => "10s"}, nil}
      ]}
    end

    test "parsing hyphenated attributes" do
      assert parse("circle stroke-width=0.5") == {:ok, [
        {:circle, %{:cx => 50, :cy => 50, :fill => "black", :r => 25, "stroke-width" => 0.5}, nil}
      ]}
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

  describe "grouping" do
    test "whitespace is significant for grouping child shapes" do
      text = """
      g transform=scale(2,2)
        circle r=20 fill=red
        circle r=10 fill=black
      square
      """

      assert parse(text) == {:ok, [
        {"g", %{"transform" => "scale(2,2)"}, [
          {:circle, %{r: 20, fill: "red", cx: 50, cy: 50}, nil},
          {:circle, %{r: 10, fill: "black", cx: 50, cy: 50}, nil}
        ]},
        {:square, %{cx: 50, cy: 50, fill: "black", r: 25}}
      ]}
    end

    test "grouping with animate tags" do
      text = """
      rect x=25 y=25 height=50 width=50
        animate attributeName=rx values=0;5;0 dur=10s repeatCount=indefinite
      """

      assert parse(text) == {:ok, [
        {"rect", %{"height" => 50, "width" => 50, "x" => 25, "y" => 25}, [
          {"animate", %{"attributeName" => "rx", "values" => "0;5;0", "dur" => "10s", "repeatCount" => "indefinite"}, nil}
        ]}
      ]}
    end
  end

  test "parsing quoted arguments" do
    text = ~S{circle cx="40" cy="30"}
    assert parse(text) == {:ok, [
      {:circle, %{cx: 40, cy: 30, r: 25, fill: "black"}, nil}
    ]}
  end

  test "invalid syntax" do
    assert {:error, _message, _str, _, _, _} = parse("_-+/*#%&(*&")
  end
end
