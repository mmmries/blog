defmodule Showoff.KidParser do
  import NimbleParsec

  def parse(str) do
    try do
      with {:ok, raw, _, _, _, _} <- pparse(str),
          tuples when is_list(tuples) <- convert_to_tuples(raw) do
        {:ok, Enum.reverse(tuples)}
      end
    rescue
      _ -> {:error, "invalid shape"}
    end
  end

  def convert_to_tuples(raw) do
    Enum.reduce_while(raw, [], fn(parsed, list) ->
      case convert_to_tuple(parsed) do
        {:error, err} -> {:halt, {:error, err}}
        tuple -> {:cont, [tuple | list]}
      end
    end)
  end

  @default_attributes %{
    cx: 50,
    cy: 50,
    r: 25,
    fill: "black"
  }

  @polygons [
    "triangle",
    "square",
    "pentagon",
    "hexagon",
    "octagon"
  ]

  @svg_tags [
    "a",
    "altGlyph",
    "altGlyphDef",
    "altGlyphItem",
    "animate",
    "animateColor",
    "animateMotion",
    "animateTransform",
    "animation",
    "circle",
    "clipPath",
    "color-profile",
    "cursor",
    "defs",
    "desc",
    "discard",
    "ellipse",
    "feBlend",
    "feColorMatrix",
    "feComponentTransfer",
    "feComposite",
    "feConvolveMatrix",
    "feDiffuseLighting",
    "feDisplacementMap",
    "feDistantLight",
    "feDropShadow",
    "feFlood",
    "feFuncA",
    "feFuncB",
    "feFuncG",
    "feFuncR",
    "feGaussianBlur",
    "feImage",
    "feMerge",
    "feMergeNode",
    "feMorphology",
    "feOffset",
    "fePointLight",
    "feSpecularLighting",
    "feSpotLight",
    "feTile",
    "feTurbulence",
    "filter",
    "font",
    "font-face",
    "font-face-format",
    "font-face-name",
    "font-face-src",
    "font-face-uri",
    "foreignObject",
    "g",
    "glyph",
    "glyphRef",
    "handler",
    "hkern",
    "line",
    "linearGradient",
    "listener",
    "marker",
    "mask",
    "metadata",
    "missing-glyph",
    "mpath",
    "path",
    "pattern",
    "polygon",
    "polyline",
    "prefetch",
    "radialGradient",
    "rect",
    "set",
    "solidColor",
    "stop",
    "switch",
    "symbol",
    "tbreak",
    "text",
    "textArea",
    "textPath",
    "title",
    "tref",
    "tspan",
    "unknown",
    "use",
    "view",
    "vkern"
  ]

  def convert_to_tuple([str]) when is_binary(str) do
    convert_to_tuple([str, []])
  end

  def convert_to_tuple([shape, attributes]) when shape in @polygons do
    attributes = Enum.reduce(attributes, @default_attributes, fn [name, value], attrs ->
      name = maybe_to_atom(name)
      Map.put(attrs, name, value)
    end)
    shape = String.to_existing_atom(shape)
    {shape, attributes}
  end

  def convert_to_tuple(["circle", attributes]) do
    attributes = Enum.reduce(attributes, @default_attributes, fn [name, value], attrs ->
      name = maybe_to_atom(name)
      Map.put(attrs, name, value)
    end)
    {:circle, attributes, nil}
  end

  def convert_to_tuple([shape, attributes]) when shape in @svg_tags do
    attributes = Enum.reduce(attributes, %{}, fn [key, value], map ->
      Map.put(map, key, value)
    end)
    {shape, attributes, nil}
  end

  def convert_to_tuple([_shape, _attributes]) do
    raise "invalid tag"
  end

  defp maybe_to_atom("cx"), do: :cx
  defp maybe_to_atom("cy"), do: :cy
  defp maybe_to_atom("r"), do: :r
  defp maybe_to_atom("fill"), do: :fill
  defp maybe_to_atom(other), do: other

  defparsec :pparse, parsec(:shapes)

  whitespace = ascii_char([32, ?\t])
               |> times(min: 1)
  attr_name = ascii_string([?a..?z, ?-], min: 1, max: 20)
  attr_pair = attr_name
                  |> ignore(ascii_char([?=]))
                  |> ascii_string([?a..?z, ?A..?Z, ?0..?9, ?!..?/], min: 1)
  shape = wrap(
            ascii_string([?a..?z], min: 1, max: 12)
            |> optional(wrap(repeat(ignore(repeat(whitespace)) |> wrap(attr_pair))))
          )

  comment =
    string("'")
    |> ascii_string([not: ?\n..?\r], min: 0)

  defcombinatorp(:shape, shape)

  newline = choice([
    ascii_char([?\n, ?\r]),
    string("\r\n")
  ])

  line = choice([
    ignore(comment),
    shape
  ])

  defcombinatorp(:shapes, line |> optional(repeat(ignore(repeat(newline)) |> concat(line))))
end
