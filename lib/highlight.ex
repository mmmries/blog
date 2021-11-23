defmodule Highlight do
  @moduledoc """
  Adapted from https://github.com/elixir-lang/ex_doc/blob/d5cde30f55c7e0cde486ec3878067aee82ccc924/lib/ex_doc/highlighter.ex
  This module works along with the prism.js additions that are loaded into the application layout.
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
    #filename = sample_filename(lang)
    #IO.inspect({:highlight, lang, filename})
    #{:ok, highlighted} = code(filename, code |> unescape_html() |> IO.iodata_to_binary())
    ~s(<pre class="language-#{lang}"><code class="language-#{lang}">#{code}</code></pre>)
   end
end
