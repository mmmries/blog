---
layout: post
title: "PStore is Amazing"
date: 2014-03-25 21:35
comments: true
categories: ruby
---

## TL\DR; Want to play with an object database? Skip Maglev and play with PStore.

My last few posts have been about my adventures of trying to get Puma to run on [Maglev](http://maglev.github.io/). That adventure began because [Johnny T](https://twitter.com/Johnny_T) infected my brain with the the idea of persistent objects. The idea that I could stop making applications in terms of relational tables and just create object graphs that can be persisted with ACID transactions.

# The City On a Hill

As I explored this idea I was awe struck to realize how much of my code, and how much of my time thinking about code was being spent on that barrier. I had been programming with a database in mind since the early days of my programming experience. I had brainwashed myself into thinking of my code in terms of the relational tables that would store my data.

You might think that removing the [Object-Relational Impedance Mismatch](http://en.wikipedia.org/wiki/Object-relational_impedance_mismatch) is a matter of convenience. Clearly not all of the logic you spend your time working on is focused on bridging that gap. So does it give you an extra 10% or maybe even 20% of your programming bandwidth back?

In my experience thus far, programming purely with objects feels like getting 50% of my bandwidth back.

# The hill

Unfortunately the reality of using Maglev today is that you will spend most of your time shaving yaks.

_Want to use RSpec to run a test?_ It raises an exception on Maglev.

_Want to use Virtus?_ The gem doesn't build on Maglev.

_Want to use Puma?_ See the recent posts.

The constant yak shave almost killed my enthusiasm for the dream.

# An Alternate Path

About a month ago I took some time off of Maglev to prepare a [presentation](http://hqmq.github.io/presentation-accidental-design/) for [Mountain West Ruby Conf](http://mtnwestrubyconf.org/). I was selected as a backup speaker in case one of the main speakers had an emergency, but the conference ran smoothly and I never ended up giving the presentation.  During my time off I found myself wondering if there were a way for me to experiment with transparent object persistence without using Maglev.

After much googling that turned up nothing of interest I remembered [PStore](http://www.ruby-doc.org/stdlib-2.1.1/libdoc/pstore/rdoc/PStore.html) which is in the Ruby Standard Library!  It supports thread-safe transactional access to a persistent root. It even notices if the same object exists multiple times in the object graph and will maintain that referential integrity. I love you PStore!

The main difference from a true object database is that it does not persist object definitions. So if you define a class and then make a bunch of instances and save them, you can only pull them back out again if your current process has loaded the definition for that class. This has turned out not to be a huge limitation in terms of my experimentation right now. I'm already used to tools that have to load my whole app into memory on boot.

# A Sample

I have begun trying to make a new backend for [my golf score app](http://golf.riesd.com/) since it is a [smallish app](https://github.com/hqmq/golf-score-grapher) with a few quirks. It makes a pretty easy testbed for trying out new ideas, while keeping focused on a defined set of functionality.

To begin with I defined a basic [Sinatra](http://www.sinatrarb.com/) app and setup the config.ru file to include a middleware which wraps every request in a PStore transaction.

```ruby config.ru
require 'my_sinatra_app'

DB = PStore.new("tmp/golfscore_grapher.pstore", true)

class DbTransactionMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    DB.transaction do
      @app.call(env)
    end
  end
end

use DbTransactionMiddleware
run GolfscoreGrapher
```

I immediately asked myself how bad the performance will be if I have to access the whole pstore all the time. So I wrote a quick rake task to import some data, made a sinatra action that accessed my pstore and generated some JSON and then benchmarked it.

```ruby
# the sinatra action
get '/players.json' do
  JSON.generate(DB[:players].map(&:attributes))
end
```

```bash
$ ab -n 1000 -c 1 'http://127.0.0.1:9292/players.json'
...
Time per request:       4.813 [ms] (mean)
...
Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       0
Processing:     4    5   1.7      4      32
Waiting:        3    5   1.7      4      32
Total:          4    5   1.7      4      32
```

# So Why Do We Need Maglev?

Clearly the PStore approach is not going to scale very well. Loading the full database on every request will become a bottlneck that can't be ignored.  But as a way to explore what it feels like to program with persistent objects it is _amazing_.

At some point I hope that an open source project will make a viable alternative to using the Gemstone system. The pure object persistence Maglev represents requires language level bindings so that new object ids don't collide with persisted object ids (plus many other concerns). Those are not easy problems to solve, but I hope that someone besides the old school of Smalltalkers will make it possible.
