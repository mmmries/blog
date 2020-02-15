---
title = "Debugging Maglev"
tags = ["ruby", "maglev", "puma"]
---

## TL/DR; Maglev still has a way to go, but they provide some very low-level information to help debug.

[Puma](http://puma.io/) is a really powerful webserver and that is something that Maglev really needs. As far as I can find the only webserver option that Maglev users have today is Webrick. I love that ruby comes with Webrick out of the box as a fast and easy way to make an HTTP server, but the benchmark below tells the story of why maglev also needs a production-ready webserver:

<!--more-->

```text Ruby 2.1.0 hello world rack app benchmark, 1000 requests, 10 at a time
                  mean   +/-sd
Webrick       26ms   5.5ms
Puma           4ms   1.4ms
```

So let's see if we can get puma to run on maglev.

First here is our most basic rack app that we will use for testing (also used for the benchmark above):

```ruby hello world rack app
app = lambda do |env| 
  [200, { 'Content-Type' => 'text/html' }, ["Hello World\n"]]
end 

run app
```

**Does it build under maglev?** YES! Puma has some native C extensions that help to make it fast. Luckily for us these extensions build just fine on the latest maglev.

**So does it work?** Uh...

```text maglev rackup with puma
$ gem install rack puma --no-ri --no-rdoc
...
$ rackup -s puma rack_app.ru
Puma 2.7.1 starting...
* Min threads: 0, max threads: 16
* Environment: development
* Listening on tcp://0.0.0.0:9292
ERROR 2702 , arg to listen must be >= 1 and <= 1000 (ArgumentError)
```

That isn't much of an error message. How can we get more? Good luck trying to google maglev debugging, but luckily I did remember [this page](http://maglev.github.io/docs/issue_tracking.html#stack_traces) on the maglev site about how to report bugs. You have to _turn on_ backtraces for maglev, because who wants a backtrace by default???

So lets try this again:

```text maglev rack with puma + backtraces
$ export MAGLEV_OPTS="-d"
michael@hair maglev-webserver
$ rackup -s puma rack_app.ru
 _____________________________________________________________________________
|                             Configuration Files                             |
|                                                                             |
| System File: /Users/michael/.rvm/rubies/maglev-head/etc/system.conf         |
    ...there is a lot of debug output now from maglev...
* Listening on tcp://0.0.0.0:9292
error , arg to listen must be >= 1 and <= 1000,
             during /Users/michael/.rvm/gems/maglev-head/bin/maglev-ruby_executable_hooks
Buffered output from initialization file /tmp/ruby.ciNi
topaz> ! Do not set the stone name in this file, maglev-ruby will override it.
    ...there's our error followed by more debug stuff, and finally it dumps us in topaz...
topaz 1> stack
==> 1 AbstractException >> _outer:with:        (envId 0) @8 line 19
    receiver [153513473 sz:20  ArgumentError] arg to listen must be >= 1 and <= 1000
    ...holy crap there is a lot of output but eventually we get to...
20 RubySocket # listen#1__                  (envId 1) @16 line 4
    receiver [153512961  TCPServer]   aTCPServer
    queue_size 1024
    aTmp1 1024
```

Maglev is not just dumping a language level stacktrace, it gives us an interpreter level strack trace with all the gory details. Amidst all those lines we can see that the 20th step before crashing it tried to call RubySocket#listen with an argument of queue_size = 1024. If we search the maglev repo for the error message it leads us [here](https://github.com/MagLev/maglev/blob/75bb360ac79c014c9ada02d47f2bb240186c6f92/src/kernel/bootstrap/Socket.rb#L361)

```ruby src/kernel/bootstrap/Socket.rb
  def listen(queue_size=10)
    queue_size = Maglev::Type.coerce_to(queue_size, Fixnum, :to_int)
    if queue_size < 1 || queue_size > 1000
      raise ArgumentError , 'arg to listen must be >= 1 and <= 1000'
    end
    self.__listen(queue_size)
    0
  end
```

So can we change puma's behavior and ask it to listen with a smaller queue size? Well if we search through some of puma's source code we find [this](https://github.com/puma/puma/blob/4b866671dd2c604a4138f9b34e14fd98948ed52c/lib/puma/binder.rb#L193):

```ruby lib/puma/binder.rb
  def add_tcp_listener(host, port, optimize_for_latency=true, backlog=1024)
```

So lets just change our local copy of the gem to default to the backlog to 512. And try to run it again:

```text maglev rack with puma (backlog=512) + backtraces
* Listening on tcp://0.0.0.0:9292
Error in reactor loop escaped: NoMethodError: undefined method `timeout_at' for NilClass (NoMethodError)
/Users/michael/.rvm/gems/maglev-head/gems/puma-2.7.1/lib/puma/reactor.rb:65:in `run_internal'
/Users/michael/.rvm/rubies/maglev-head/src/kernel/bootstrap/Array.rb:886:in `each'
```

We will get this error repeating infinitely and curl requests will timeout without a response.

Clearly this rabbit hole goes deeper and we still need to shave a few yaks before we can get puma running, but knowing how to debug in maglev has pointed us in the right direction.
