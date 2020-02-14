defmodule Highlight do
  @moduledoc """
  This module assumes that you have a [syntect server](https://github.com/sourcegraph/syntect_server)
  running locally. It highlights code by sending it to the API
  of that server and returns HTML.
  """

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
