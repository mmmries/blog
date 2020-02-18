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

  def get_post(date, slug) do
    case find_post(date, slug) do
      nil -> {:error, :not_found}
      post -> {:ok, post}
    end
  end

  def get_posts_by_tag(tag) do
    Enum.filter(@posts, fn(post) ->
      tag in post.tags
    end)
  end

  def list_posts do
    @posts
  end

  def list_tags do
    @posts |> Enum.flat_map(&( Map.get(&1, :tags, []))) |> Enum.uniq() |> Enum.sort()
  end

  defp find_post(date, slug) do
    Enum.find(@posts, fn(post) ->
      post.date == date and post.slug == slug
    end)
  end
end
