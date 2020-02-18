---
title = "Full Text Search In Memory"
tags = ["elixir", "bayesic", "otp"]
---

I recently read about [dashbit building their blog](https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made) with a simple macro that compiled their posts into an in-memory data structure.
I loved the idea of having a dynamic server, but doing most of the work up-front to keep things efficient and fast.
One of the drawbacks they mention in their post is supporting full-text search.
I had a flight coming up and this felt like a good project to see if I could get full-text searching working in the BEAM.

## The Setup

First I switched my [jekyll blog to a setup similar to dashbit]().
It's not quite the same since I need to syntax highlight ruby and other languages in some posts and I wanted to keep my links backwards compatible.
Once that was done, I pulled [bayesic](https://hex.pm/packages/bayesic) and [stemmer](https://hex.pm/packages/stemmer) into the project since I planned to use them for my search index.

## How To Search Text

I decided to use a fairly simple approach to text search.
[Bayesic](https://hex.pm/packages/bayesic) implements probabilistic string matching via [Bayes Theorem](https://en.wikipedia.org/wiki/Bayes%27_theorem).
In essence, for each bit of a string we are searching, we see how common that bit is across all blog posts and then adjust our best guess of which posts you might be interested one bit of string at a time.
I combined this approach with [stemmer](https://hex.pm/packages/stemmer) to find all the word roots for each word in my blog posts and then break those into trigrams.
This means that as soon as the user has typed 3 letters we can start to provide search results, but we will weight the value of each 3 letters based on how commonly they are used.
This process of building and querying a search index can be seen in [the Blog.Search module](#).

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

![network timing for searches](/assets/images/2020-02-18/query_network_timing.png)

You can see that the time between me typing the next later is ~100ms and the time to send the query and get a response is ~1ms.

## Infrastructure In The BEAM

This is a great example of the BEAM giving us options around infrastructure.
I can offer a solid search experience on my blog without needing postgres extensions, or elasticsearch or any other runtime dependency.

There are, of course, more complete solutions that exist outside of the BEAM.
This type of GenServer solution is not a great option if you have GB worth of text index or need more advanced text search capabilities.
In those cases you would probably want something like ElasticSearch, but the tradeoff of 1.7sec before search is available after boot and an extra 5MB of memory usage are definitely preferable to me managing another service for my blog.

I don't think this blog will be getting an amount of search that might overwhelm a single GenServer any time soon :)