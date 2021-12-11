defmodule Showoff.KidParser do
  import NimbleParsec

  def parse(str) do
    with {:ok, raw, _, _, _, _} <- pparse(str) do
      raw
      |> Enum.map(&convert_to_tuple/1)
    end
  end

  def convert_to_tuple([str]) when is_binary(str) do
    {String.to_existing_atom(str), %{}, nil}
  end

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
            |> optional(repeat(ignore(repeat(whitespace)) |> wrap(attr_pair)))
          )
  defcombinatorp(:shape, shape)

  newline = choice([
    ascii_char([?\n, ?\r]),
    string("\r\n")
  ])

  defcombinatorp(:shapes, shape |> optional(repeat(concat(newline, shape))))
end
