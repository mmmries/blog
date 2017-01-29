---
layout: post
title: "puma mostly running on maglev"
date: 2014-02-28 22:43
comments: true
tags: ruby maglev puma
---

## TL\DR; Puma runs on maglev with a few caveats. Full support is around the corner?

My [last post](/blog/2014/02/26/puma-runs-on-maglev) was a perfect example of why you shouldn't post something until you are sure...

But it turns out that I wasn't too far off. [Tim's IO.select fix](https://github.com/MagLev/maglev/tree/tim/github313) got us past the first hurdle and once he had fixed that puma would run, but it would hang on every request.

<!--more-->

## The Problem

I have never wished so much that a program would just crash and fail rather than hang. Since I have no experience running a real debugger or profiler in Maglev I had to fall back to the tried and trusty "puts debugging" technique. This also meant going on a deep dive through [Puma's](http://puma.io/) [codebase](https://github.com/puma/puma).

It has been a while since I had last worked on a codebase that made heavy use of Thread, mutexes and reactors. Luckily for me Puma uses all of them at the same time! Eventually I found the call to IO.read_nonblock that was causing the issue. I wrote [a little gist](https://gist.github.com/hqmq/9278656) to narrow down the problem and [submitted an issue](https://github.com/MagLev/maglev/issues/338) on the Maglev repo. After the fast fix I got from Tim on the IO.select problem I figured submitting an issue was probably good enough.

## The Journey

This morning at work I had a nagging feeling. My "Open Source Conscience" was burning. Why was I waiting for someone else to fix the bug? I am definitely not qualified to try to fix low-level issues on a language implementation, but I should at least try.

So on my lunch break I sat on a couch with my laptop and started reading through source code. [Johnny T](https://github.com/johnnyt) suggested I take a look at how [Rubinius](http://rubini.us/) implemented the method, but Rubinius was using lots of things specific to their implementation of an IO object whereas Maglev was leaning heavily on the smalltalk/Gemstone implementation of IO. So there wasn't much in common.

Then it dawned on me that read_nonblock was really just a wrapper around a system level call. There shouldn't be much implementation to even look at. Gemstone definitely runs other web servers and they certainly must be using some of the same sort of IO primitives as puma uses. So I went back to my dear friend IRB.

## The Discovery

The IRB session went something like this:

```
$ maglev-irb
irb(main):001:0> sock = TCPSocket.new('127.0.0.1', 2000)
=> #<TCPSocket:0xca63501 @_st_fileDescriptor=12 @_st_lineNumber=nil @_st_readWaiters=nil @_st_writeWaiters=nil @_st_readyEvents=0 @_st_pollArrayOfs=-1 @_st_selectWaiters=nil @_st_readBuffer=nil @_st_bufferOffset=nil @_st_isRubyBlocking=true>
irb(main):002:0> (sock.methods - Object.methods).sort
=> ["<<", "accept", "accept_nonblock", "addr", "all?", "any?", "bind", "binmode", "bytes", "chars", "close", "close_read", "close_write", "closed?", "collect", "connect", "connect_nonblock", "connected?", "count", "cycle", "detect", "drop", "drop_while", "each", "each_byte", "each_char", "each_cons", "each_line", "each_slice", "each_with_index", "ensure_open_and_readable", "ensure_open_and_writable", "entries", "enum_cons", "enum_slice", "enum_with_index", "eof?", "fcntl", "fileno", "find", "find_all", "find_index", "first", "flush", "fsync", "getbyte", "getc", "getpeername", "gets", "getsockname", "getsockopt", "grep", "group_by", "inject", "isatty", "lineno", "lineno=", "lines", "listen", "map", "max", "max_by", "member?", "min", "min_by", "minmax", "minmax_by", "none?", "one?", "partition", "peeraddr", "pid", "print", "printf", "putc", "puts", "read", "read_nonblock", "readchar", "readline", "readlines", "readpartial", "recv", "recv_nonblock", "recvfrom", "recvfrom_nonblock", "reduce", "reject", "reopen", "reverse_each", "rewind", "seek", "select", "set_blocking", "setsockopt", "shutdown", "sort", "sort_by", "sorter", "stat", "sync", "sync=", "sysaccept", "sysread", "sysseek", "syswrite", "take", "take_while", "to_i", "to_io", "tty?", "ungetc", "write", "zip"]
```

Sitting nearby the read methods there was something called recv_nonblock. A quick grep through the codebase showed that this method accepts two parameters, a maximum number of bytes to read and an optional string buffer to copy bytes into.  That sounds just like read_nonblock.

## The Solution

So I opened the definition for IO and added this:

```ruby src/kernel/bootstrap/IO.rb
def read_nonblock(*args)
  recv_nonblock(*args)
end
```

Then I recompiled maglev (which by the way is awesome because it actually just reloads all the ruby definitions into the persistent stone) and tried to run my little gist and it worked! So I forked the maglev repo, pushed up my changes to a branch on my fork and submitted a [pull request](https://github.com/MagLev/maglev/pull/339). This pull request got merged within a few hours!

## So Puma runs now???

YES! Puma 2.8.0 runs out of the box on magelv (once Tim's pull request gets merged).

## How Fast Is It???

Running the same "Hello World" rack app as my previous post here are the quick numbers by testing with "ab -n 1000 -c 10 http://127.0.0.1:9292/"
<table style="text-align: right;" cellpadding="10">
  <thead>
    <tr>
      <th>&nbsp;</th>
      <th>mean (ms)</th>
      <th>standard deviation (ms)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Ruby 2.1.0</td>
      <td>2.691</td>
      <td>0.9</td>
    </tr>
    <tr>
      <td>Maglev Head + Tim's Fix</td>
      <td>7.081</td>
      <td>0.8</td>
    </tr>
  </tbody>
</table>

## What about those caveats you mentioned?

 * Trying to use clustered mode (ie multiple processes) throws an error about SIGCHILD
 * I have seen Puma hang under heavy load on in this setup
 * I still haven't tested every feature that Puma supports

## The Moral of the Story

So Puma+Maglev works at a basic level and is nearly as fast as Puma+2.1.0. But the real moral of the story is to go and try something. I am totally unqualified to understand all the nuances of a webserver like Puma. I am barely even capable of reading a lot of Maglev's source code. But even I was able to find a problem and a solution just because I wanted to see something happen and I was willing to spend a little bit of time on it.

I'm sure someone with a better understanding of Gemstone would have been able to use a better debugging technnique than a bunch of puts statements. I'm sure they could find a more clever solution to the read_nonblock problem, but something works today that didn't work yesterday because I tried. That is pretty cool.
