defmodule BlogWeb.HomepageLive do
  use BlogWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="home">
      <h1 class="page-heading">Posts</h1>

      <ul class="post-list">
        <%= for post <- @posts do %>
          <li>
            <span class="post-meta">{post.date}</span>
            <h2><.post_link post={post} /></h2>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    posts = Blog.list_posts()
    {:ok, assign(socket, :posts, posts)}
  end
end
