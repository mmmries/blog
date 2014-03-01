---
layout: post
title: "Puma runs on Maglev"
date: 2014-02-26 21:22
comments: true
categories: ruby maglev puma
published: true
---

## Edit: After writing this I discovered that there was an problem with my GEM_PATH environment variable so puma was actually running under MRI. No Wonder it was running at almost the exact same speed as MRI :) Sorry for the false information.

In my last post I talked about debugging my problems when trying to get puma running under maglev.  In just a few short days I've gotten help on teh mailing list, at a users group and on the [Maglev](https://github.com/MagLev/maglev/issues/313) github repo. The result of that help is that I can run puma under Maglev!

## What patches?

There is a small patch that has to be made to the puma gem itself to make it read with a [smaller backlog size](https://github.com/puma/puma/blob/e4cf1573f13cca1fcea281af8acf6f452803d545/lib/puma/binder.rb#L193) of 512 to avoid a problem with Gemstone. I plan on making a pull request that lets you configure this in your normal puma config file.

[Tim Felgentreff](https://github.com/timfel) made a branch on maglev that fixes an issue with using <code>Kernel.select</code> with <code>Pipe</code> objects. It looks like the branch builds just fine so I expect it will find its way into master pretty soon.

That means that within a small time (a couple days or weeks?) you will be able to run puma out of the box on maglev with just a configuration tweak.

## Performance?

Micro-benchmarks are not meaningful blah blah blah...

But I can't seem to post without some numbers. The whole reason I started looking into this was because people will walk away from Maglev purely on the basis that Webrick is the only option for a webserver. So this needs to not only run, but run pretty quickly if it is going to be worth the effort.

These tests were done with Puma 2.7.1 (in quite mode to avoid console IO skewing the results) running 2 workers with 4 threads each and a "Hello World" rack app. Once the webserver was running we hit it with apache benchmark like this: <code>ab -c 10 -n 5000 'http://127.0.0.1:9292/'</code>

_Ruby 2.1.0_
```
mean  2ms (+/- 0.7ms standard deviation)
```

_Maglev tim/github313 branch_
```
mean 2ms (+/- 0.7ms standard deviation)
```

I tried several other settings of number of workers and threads and Ruby 2.1.0 and Maglev are neck and neck on every benchmark.

## Wrapup

This all boils down to the fact that Maglev is approaching a point where you can get all the nice Maglev/Gemstone candy without making huge sacrifices about what tools you can use and what performance you can expect.

It also proves that people are actively working on making Maglev better so the tools and processes will continue to improve.
