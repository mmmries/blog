defmodule Highlight do
  @moduledoc """
  Adapted from https://github.com/elixir-lang/ex_doc/blob/d5cde30f55c7e0cde486ec3878067aee82ccc924/lib/ex_doc/highlighter.ex
  This module assumes that you have a [syntect server](https://github.com/sourcegraph/syntect_server)
  running locally. It highlights code by sending it to the API
  of that server and returns HTML.
  """

   @doc """
   Highlights all code block in an already generated HTML document.
   """
   def highlight_code_blocks(html, opts \\ []) do
     Regex.replace(
       ~r/<pre><code(?:\s+class="(\w*)")?>([^<]*)<\/code><\/pre>/,
       html,
       &highlight_code_block(&1, &2, &3, opts)
     )
   end

   defp highlight_code_block(_full_block, lang, code, _outer_opts) do
    filename = sample_filename(lang)
    IO.inspect({:highlight, lang, filename})
    {:ok, highlighted} = code(filename, code |> unescape_html() |> IO.iodata_to_binary())
    ~s(<code class="#{lang}">#{highlighted}</code>)
   end

   defp sample_filename("ruby"), do: "example.rb"
   defp sample_filename("elixir"), do: "example.exs"
   defp sample_filename("shell"), do: "example.sh"
   defp sample_filename(_other), do: "example.txt"

   entities = [{"&amp;", ?&}, {"&lt;", ?<}, {"&gt;", ?>}, {"&quot;", ?"}, {"&#39;", ?'}]

   for {encoded, decoded} <- entities do
     defp unescape_html(unquote(encoded) <> rest) do
       [unquote(decoded) | unescape_html(rest)]
     end
   end

   defp unescape_html(<<c, rest::binary>>) do
     [c | unescape_html(rest)]
   end

   defp unescape_html(<<>>) do
     []
   end

  @url 'http://localhost:9238/'
  @content_type 'application/json'
  @theme "Solarized (dark)"
  def code(filename, code) do
    request_body = Jason.encode!(%{
      "filepath" => filename,
      "theme" => @theme,
      "code" => code
    })
    request = {@url, [], @content_type, request_body}
    case :httpc.request(:post, request, [], []) do
      {:ok, {{_, 200, _}, _headers, body}} ->
        html = Jason.decode!(body) |> Map.get("data")
        {:ok, html}
      other ->
        require Logger
        Logger.error("Failed to highlight: #{inspect(other)}")
        {:error, "failed to highlight"}
    end
  end
end
