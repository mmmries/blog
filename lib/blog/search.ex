defmodule Blog.Search do
  def build_index(posts) do
    posts
    |> Enum.reduce(Bayesic.Trainer.new(), fn(post, trainer) ->
      tokens = post.body |> Floki.parse_fragment!() |> Floki.text() |> tokenize()
      Bayesic.train(trainer, tokens, post)
    end)
    |> Bayesic.finalize(pruning_threshold: 0.5)
  end

  @min_probability 0.2
  def search(index, query, max_matches \\ 5) do
    Bayesic.classify(index, tokenize(query))
    |> Enum.filter(fn({_post, probability})->
      probability > @min_probability
    end)
    |> Enum.sort_by(fn({_post, probability}) ->
      probability * -1
    end)
    |> Enum.take(max_matches)
    |> Enum.map(fn({post, _probability}) -> post end)
  end

  def tokenize(str) do
    Regex.scan(~r{\b\w+\b}, String.downcase(str))
    |> Enum.reduce(MapSet.new(), fn(matches, set) ->
      word = hd(matches)
      stem = Stemmer.stem(word)
      set = stem |> trigrams() |> Enum.into(set)
      set = word |> trigrams() |> Enum.into(set)
      set = [word, stem] |> Enum.into(set)
      set
    end)
  end

  def trigrams(word) do
    word
    |> String.graphemes()
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(&Enum.join/1)
  end
end
