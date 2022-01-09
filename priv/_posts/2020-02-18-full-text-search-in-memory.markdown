---
title = "Full Text Search In Memory"
tags = ["elixir", "bayesic", "otp"]
---

I recently read about [dashbit building their blog](https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made) by compiling their blog posts into a module attribute.
I loved the idea of having a dynamic server, but doing most of the work up-front to keep things efficient and fast.
No database, no filesystem permissions, no nginx configs.
I had been wanting to migrate my blog off of [jekyll](https://rubygems.org/gems/jekyll) for a while, so I decided to jump in.

As I was thinking about the power of a dynamic server with in-memory data structures, I started wondering how hard it would be to support full-text search.
I loved the tags implementation that Dashbit had used and it seemed like something similar could be done to support text search.

## The Setup

First I switched my [jekyll blog to a setup similar to dashbit](https://github.com/mmmries/blog/compare/e07e6f221e5d5800fd7cff382ef684479d1a8aaa...eb6aa7fa3385ed2e8be58bd61d6f7158c5780f7e).
It's not quite the same since I need to syntax highlight ruby and other languages in some posts and I wanted to keep my links backwards compatible.
Once that was done, I pulled [bayesic](https://hex.pm/packages/bayesic) and [stemmer](https://hex.pm/packages/stemmer) into the project since I planned to use them for my search index.

## How To Search Text

I decided to use a fairly simple approach to text search.
[Bayesic](https://hex.pm/packages/bayesic) implements probabilistic string matching via [Bayes Theorem](https://en.wikipedia.org/wiki/Bayes%27_theorem).
Imagine taking each word in a blog post and breaking into trigrams.
The word `theme` becomes `the`, `hem`, and `eme`.
When a user enters `themes` we break their search query into the pieces `the`, `hem`, `eme`, and `mes`.
We can look at `the` and see that it exists in our target text as well as the search query, but this trigram is very common, so that doesn't influence our search results very much.
Next we also see that `hem` and `eme` are matches and these are less common.
Each of these small observations changes the liklihood that our search query was intending to find a given target and we can then sort the results and pick the five most likely targets.

I combined this approach with [stemmer](https://hex.pm/packages/stemmer) to find all the word roots for each word in my blog posts.
The combination of these two approaches should help us to generate a variety of tokens that a user might enter when searching for a given word.
This process of building and querying a search index can be seen in [the Blog.Search module](https://github.com/mmmries/blog/blob/32942ea637abedf16fe056666c3387c43223d673/lib/blog/search.ex).

## Compile Time vs Boot Time

My first experiment was to build the text index at compilation time like we do for the blog posts.
But this resulted in slow compile times of 15+ sec for the module containing the full text search index.
The resulting beam file was 37M (compared to the 215kb module that contained the actual posts).

Next I pulled the text index out into a [GenServer](https://github.com/elixir-lang/elixir/blob/v1.10.1/lib/elixir/lib/gen_server.ex) which is started when the app boots.
This took ~1.7sec to build the index and the process ends up with a heap size of ~4.5MB.
I'm not sure why there is a large discrepancy between the size/time of compiling the beam file vs just building it in-memory 🤷‍♂️🤷‍♀️, but using a GenServer seems to be fine in terms of memory-usage and speed.
When querying the index it takes between 60µs and 1ms to do a search depending on query size and number of results.

## Connecting to Phoenix

I pulled [Phoenix Live View](https://github.com/phoenixframework/phoenix_live_view/blob/v0.7.1/lib/phoenix_live_view.ex) into the project and added a [SearchLive module]() to the header of my layout.
Each time the user changes the input box an event is sent back to the live view process which in turn queries the `SearchServer` process and then updates the list of results.
This is all done in ~1-2ms and I didn't have to name any endpoints or decide on how to render results etc.

![network timing for searches](/images/2020-02-18/query_network_timing.png)

You can see that the it takes ~100ms for my fingers to type the next letter, but the time to send the query and get a response is only ~1ms.

## Infrastructure In The BEAM

This is a great example of the BEAM giving us options around infrastructure.
I can offer a solid search experience on my blog without needing postgres extensions, or elasticsearch or any other runtime dependency.

There are, of course, more complete solutions that exist outside of the BEAM.
This type of GenServer solution is not a great option if you have GB worth of text index or need more advanced text search capabilities.
In those cases you would probably want something like ElasticSearch, but the tradeoff of 1.7sec before search is available after boot and an extra 5MB of memory usage are definitely preferable to me managing another service for my blog.

I don't think this blog will be getting an amount of search that might overwhelm a single GenServer any time soon :)