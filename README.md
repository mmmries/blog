# Blog

My personal blog

## Writing

When I'm writing locally for this blog make sure to start the syntax highlighting server and then run:

```shell
$ mix deps.get
$ mix phx.server
```

## Syntax Highlighting

> Note: I've temporarily switched to using prism.js (loaded from a CDN) for code highlighting.
> I would prefer to have a compile-time dependency rather than a run-time dependency for the user, but I couldn't get Elixir highlighting correctly.
> See https://github.com/sourcegraph/syntect_server/issues/27 for details.

In order to support syntax highlighting for a variety of languages I am using the [syntect_server](https://github.com/sourcegraph/syntect_server) project.
You can easily start this up locally via docker:

```
$ docker run -it --rm --name=syntect_server -p 9238:9238 sourcegraph/syntect_server
```

No syntax highlighting is required at runtime, only while compiling posts.

## Deploying

To build a release, run the command (change out the date and version number):

```
$ mix publish
# if you want to use a specific tag, just pass it as the first argument
$ mix publish 2020.02.23.2
```