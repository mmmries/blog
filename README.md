# Blog

My personal blog

## Writing

When I'm writing locally for this blog, I run the following steps to get the server up and running.
It should reload immediately when changes are made.

```shell
$ mix deps.get
$ iex -S mix phx.server
```

## Deploying

This blog is deployed using [Fly](https://fly.io).
When changes are ready to be published, make sure [you have installed flyctl](https://fly.io/docs/hands-on/installing/) and then run `fly deploy` in the home directory.
If you are on an M1 mac there may be some architecture issues, so you need to run `fly deploy --remote-only` to build the docker image on a remote host.