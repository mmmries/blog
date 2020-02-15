defmodule BlogWeb.PageView do
  use BlogWeb, :view

  def post_link(post) do
    post_url = (Date.to_iso8601(post.date) |> String.replace("-", "/")) <> "/#{post.slug}.html"
    link(post.title, to: post_url, class: "post-link")
  end
end
