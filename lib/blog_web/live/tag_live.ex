defmodule BlogWeb.TagLive do
  use BlogWeb, :live_view

  def render(assigns) do
    ~H"""
    <h2>{@tag}</h2>
    <ul>
      <%= for post <- @posts do %>
        <li>
          <.post_link post={post} />
          ({Date.to_iso8601(post.date)} | Tags: {Enum.join(post.tags, ", ")})
        </li>
      <% end %>
    </ul>
    """
  end

  def mount(%{"name" => tag}, _session, socket) do
    tag = trim_slug(tag)
    posts = Blog.get_posts_by_tag(tag)

    socket =
      socket
      |> assign(:tag, tag)
      |> assign(:posts, posts)

    {:ok, socket}
  end

  defp trim_slug(slug) do
    String.trim_trailing(slug, ".html")
  end
end
