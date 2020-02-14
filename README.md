# Blog

My personal blog

## Writing

When I'm writing locally for this blog make sure to start the syntax highlighting server and then run:

```shell
$ mix deps.get
$ mix phx.server
```

## Syntax Highlighting

In order to support syntax highlighting for a variety of languages I am using the [syntect_server](https://github.com/sourcegraph/syntect_server) project.
You can easily start this up locally via docker:

```
$ docker run -it --rm --name=syntect_server -p 9238:9238 sourcegraph/syntect_server
```

No syntax highlighting is required at runtime, only while compiling posts.