defmodule Blog.Post do
  @enforce_keys [:title, :body, :slug, :tags, :date]
  defstruct [:title, :body, :slug, :tags, :date]

  def parse!(path) do
    {date, slug} = parse_path(path)
    attributes = parse_file_content(path)

    %__MODULE__{
      title: attributes.title,
      body: attributes.body,
      slug: slug,
      tags: attributes.tags,
      date: date
    }
  end

  defp parse_file_content(path) do
    IO.inspect(path)
    {metadata, content} = read_file(path)

    %{
      title: Map.fetch!(metadata, "title"),
      body: transform(content, Path.extname(path)),
      tags: Map.get(metadata, "tags", [])
    }
  end

  defp read_file(path) do
    raw = File.read!(path)
    [_full, meta_str, content] = Regex.run(~r{\A---\n(.*)\n---\n\n(.*)\z}us, raw)
    metadata = Toml.decode!(meta_str)
    {metadata, content}
  end

  defp transform(html, ".html"), do: html |> Highlight.highlight_code_blocks()

  defp transform(markdown, ".markdown"),
    do: Earmark.as_html!(markdown) |> Highlight.highlight_code_blocks()

  # _posts/2012-03-18-welcome.html
  # _posts/2013-10-09-you-should-sleep-on-it.markdown
  defp parse_path(path) do
    filename = Path.basename(path)

    date =
      filename
      |> String.split("-")
      |> Enum.take(3)
      |> Enum.join("-")
      |> Date.from_iso8601!()

    slug = slug_from_filename(filename)
    {date, slug}
  end

  defp slug_from_filename(filename) do
    parts = filename |> String.split_at(11) |> elem(1) |> String.split(".")
    Enum.slice(parts, 0, Enum.count(parts) - 1) |> Enum.join(".")
  end
end
