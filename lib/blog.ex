defmodule Blog do
  @moduledoc """
  This module is the repository of posts
  """

  alias Blog.Post

  posts_paths = "_posts/*" |> Path.wildcard() |> Enum.sort()

  posts =
    for post_path <- posts_paths do
      @external_resource Path.relative_to_cwd(post_path)
      Post.parse!(post_path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  def list_posts do
    @posts
  end
end
