defmodule Showoff.KidParser do
  import NimbleParsec

  def parse(str) do
    with {:ok, raw, _, _, _, _} <- pparse(str),
        tuples when is_list(tuples) <- convert_to_tuples(raw) do
      {:ok, Enum.reverse(tuples)}
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

  @special_shapes [
    "triangle",
    "square",
    "pentagon",
    "hexagon",
    "octagon"
  ]
  def convert_to_tuple([str]) when is_binary(str) do
    convert_to_tuple([str, []])
  end

  def convert_to_tuple([shape, attributes]) when shape in @special_shapes do
    attributes = Enum.reduce(attributes, @default_attributes, fn [name, value], attrs ->
      name = maybe_to_atom(name)
      Map.put(attrs, name, value)
    end)
    shape = String.to_existing_atom(shape)
    {shape, attributes}
  end

  def convert_to_tuple([shape, attributes]) when is_binary(shape) do
    attributes = Enum.reduce(attributes, %{}, fn [key, value], map ->
      Map.put(map, key, value)
    end)
    {shape, attributes, nil}
  end

  defp maybe_to_atom("cx"), do: :cx
  defp maybe_to_atom("cy"), do: :cy
  defp maybe_to_atom("r"), do: :r
  defp maybe_to_atom("fill"), do: :fill
  defp maybe_to_atom(other), do: other

  defparsec :pparse, parsec(:shapes)

  whitespace = ascii_char([32, ?\t])
               |> times(min: 1)
  attr_name = ascii_string([?a..?z], min: 1, max: 20)
  attr_pair = attr_name
                  |> ignore(ascii_char([?=]))
                  |> choice([
                    integer(min: 1),
                    attr_name
                  ])
  shape = wrap(
            ascii_string([?a..?z], min: 1, max: 12)
            |> optional(wrap(repeat(ignore(repeat(whitespace)) |> wrap(attr_pair))))
          )
  defcombinatorp(:shape, shape)

  newline = choice([
    ascii_char([?\n, ?\r]),
    string("\r\n")
  ])

  defcombinatorp(:shapes, shape |> optional(repeat(ignore(repeat(newline)) |> concat(shape))))
end
