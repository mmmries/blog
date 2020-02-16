defmodule BlogWeb.PageView do
  use BlogWeb, :view

  def post_link(post, content \\ nil) do
    post_url = "/" <> (Date.to_iso8601(post.date) |> String.replace("-", "/")) <> "/#{post.slug}.html"
    if content == nil do
      link(post.title, to: post_url, class: "post-link")
    else
      link(content, to: post_url, class: "post-link")
    end
  end
end
