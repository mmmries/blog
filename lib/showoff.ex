defmodule Showoff do
  alias Showoff.Drawing

  def dets_dir do
    case Application.get_env(:blog, :showoff_dets_dir) do
      nil ->
        :code.priv_dir(:blog) |> Path.join("drawings")

      directory ->
        directory
    end
  end

  def kid_text_to_drawing(text, author) do
    case kid_text_to_svg(text) do
      {:ok, svg} -> {:ok, %Drawing{author: author, svg: svg, text: text}}
      {:error, err} -> {:error, err}
    end
  end

  def kid_text_to_svg(text) do
    case Showoff.KidParser.parse(text) do
      {:ok, terms} -> term_to_svg(terms)
      _other -> {:error, "can't draw"}
    end
  end

  def text_to_drawing(text) do
    case text_to_svg(text) do
      {:ok, svg} -> {:ok, %Drawing{author: nil, svg: svg, text: text}}
      {:error, err} -> {:error, err}
    end
  end

  def text_to_svg(text) do
    case Showoff.TermParser.parse(text) do
      {:ok, term} -> term_to_svg(term)
      {:error, error} -> {:error, error}
    end
  end

  @doc "this should really be handled by ChunkySVG, but sometimes it just crashes when the structure does not match what it expects"
  def term_to_svg(term) do
    try do
      svg = ChunkySVG.render(term)
      {:ok, svg}
    catch
      err -> {:error, err}
      _reason, err -> {:error, err}
    end
  end
end
