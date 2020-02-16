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

  @text_index @posts |> Enum.reduce(Bayesic.Trainer.new(), fn(post, trainer) ->
    tokens = post.body |> Floki.parse_fragment!() |> Floki.text() |> Stemmer.stem()
    tokens = if is_binary(tokens) do
      [tokens]
    else
      tokens
    end
    Bayesic.train(trainer, tokens, post)
  end) |> Bayesic.finalize(pruning_threshold: 0.2)

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

  @min_probability 0.3
  def search(query, max_matches \\ 5) do
    tokens = query |> Stemmer.stem() |> force_list()
    Bayesic.classify(@text_index, tokens)
    |> Enum.filter(fn({_post, probability})->
      probability > @min_probability
    end)
    |> Enum.sort_by(fn({_post, probability}) ->
      probability * -1
    end)
    |> Enum.take(max_matches)
    |> Enum.map(fn({post, _probability}) -> post end)
  end

  defp find_post(date, slug) do
    Enum.find(@posts, fn(post) ->
      post.date == date and post.slug == slug
    end)
  end

  defp force_list(single_stem) when is_binary(single_stem), do: [single_stem]
  defp force_list(list), do: list
end
