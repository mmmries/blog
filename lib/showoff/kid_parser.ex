defmodule Showoff.KidParser do
  import NimbleParsec

  def parse(str) do
    try do
      with {:ok, raw, _, _, _, _} <- pparse(str),
           tuples when is_list(tuples) <- convert_to_tuples(raw),
           tuples <- nest(Enum.reverse(tuples)) do
        {:ok, tuples}
      end
    rescue
      _ -> {:error, "invalid shape"}
    end
  end

  def convert_to_tuples(raw) do
    Enum.reduce_while(raw, [], fn parsed, list ->
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
    "arc",
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

  def convert_to_tuple([whitespace, str]) when is_binary(str) do
    convert_to_tuple([whitespace, str, []])
  end

  def convert_to_tuple([whitespace, shape, attributes]) when shape in @polygons do
    attributes =
      Enum.reduce(attributes, @default_attributes, fn [name, value], attrs ->
        name = maybe_to_atom(name)
        Map.put(attrs, name, value)
      end)

    shape = String.to_atom(shape)
    {Enum.count(whitespace), shape, attributes}
  end

  def convert_to_tuple([whitespace, "circle", attributes]) do
    attributes =
      Enum.reduce(attributes, @default_attributes, fn [name, value], attrs ->
        name = maybe_to_atom(name)
        Map.put(attrs, name, value)
      end)

    {Enum.count(whitespace), :circle, attributes, nil}
  end

  def convert_to_tuple([whitespace, shape, attributes]) when shape in @svg_tags do
    attributes =
      Enum.reduce(attributes, %{}, fn [key, value], map ->
        Map.put(map, key, value)
      end)

    {Enum.count(whitespace), shape, attributes, nil}
  end

  def convert_to_tuple([_shape, _attributes]) do
    raise "invalid tag"
  end

  defp maybe_to_atom("cx"), do: :cx
  defp maybe_to_atom("cy"), do: :cy
  defp maybe_to_atom("r"), do: :r
  defp maybe_to_atom("fill"), do: :fill
  defp maybe_to_atom(other), do: other

  # Takes in a flat list of tuples and turns it into a nested list depending on depth of indentation
  #
  # Each tuple in the list is either a 3 tuple of {depth, tag_name, attributes} or a pseudo nested
  # 4 tuple of {depth, tag_name, attributes, children} where `children` will always be nil. The
  # 3 tuples represent special shapes that cannot have children and get expanded by ChunkySVG.

  # In the nested structure that we return, the depth elements will all be removed and we will have
  # taken any deeper indentations and nested them as the children the element before them.
  defp nest(tuples) do
    {nested, []} = nest(tuples, 0, [])
    nested
  end

  def nest([], _previous_depth, in_progress) do
    {Enum.reverse(in_progress), []}
  end

  def nest([tuple | rest], depth, in_progress) do
    tuple_depth = elem(tuple, 0)

    cond do
      tuple_depth == depth ->
        in_progress = [strip_depth(tuple) | in_progress]
        nest(rest, depth, in_progress)

      tuple_depth > depth ->
        {nested_list, rest} = nest([tuple | rest], tuple_depth, [])
        in_progress = append_children(in_progress, Enum.reverse(nested_list))
        nest(rest, depth, in_progress)

      tuple_depth < depth ->
        {in_progress, [tuple | rest]}
    end
  end

  defp strip_depth({_d, tag, attrs, nil}), do: {tag, attrs, nil}
  defp strip_depth({_d, tag, attrs}), do: {tag, attrs}

  defp append_children([{tag, attrs, nil} | rest], children) do
    [{tag, attrs, children} | rest]
  end

  defp maybe_to_num(str) do
    cond do
      Regex.match?(~r{\A\d+\z}, str) ->
        String.to_integer(str)

      Regex.match?(~r{\A[+-]?([0-9]*[.])?[0-9]+\z}, str) ->
        String.to_float(str)

      true ->
        str
    end
  end

  defp not_quote(<<?", _::binary>>, context, _, _), do: {:halt, context}
  defp not_quote(_, context, _, _), do: {:cont, context}

  defparsec(:pparse, parsec(:shapes))

  whitespace =
    ascii_char([32, ?\t])
    |> times(min: 1)

  attr_name = ascii_string([?a..?z, ?-, ?A..?Z], min: 1, max: 20)
  bare_attr_value = map(ascii_string([?!, ?#..?~], min: 1), :maybe_to_num)

  quoted_attr_value =
    ignore(ascii_char([?"]))
    |> repeat_while(
      choice([
        ~S(\") |> string() |> replace(?"),
        utf8_char([])
      ]),
      {:not_quote, []}
    )
    |> ignore(ascii_char([?"]))
    |> reduce({List, :to_string, []})
    |> map(:maybe_to_num)

  attr_pair =
    attr_name
    |> ignore(ascii_char([?=]))
    |> concat(
      choice([
        bare_attr_value,
        quoted_attr_value
      ])
    )

  shape =
    wrap(
      optional(wrap(repeat(whitespace)))
      |> ascii_string([?a..?z, ?A..?Z], min: 1, max: 12)
      |> optional(wrap(repeat(ignore(repeat(whitespace)) |> wrap(attr_pair))))
    )

  comment =
    string("'")
    |> ascii_string([not: ?\n..?\r], min: 0)

  defcombinatorp(:shape, shape)

  newline =
    choice([
      ascii_char([?\n, ?\r]),
      string("\r\n")
    ])

  line =
    choice([
      ignore(comment),
      shape
    ])

  defcombinatorp(:shapes, line |> optional(repeat(ignore(repeat(newline)) |> concat(line))))
end
