# Blog

My personal blog

## Writing

When I'm writing locally for this blog, I run the following steps to get the server up and running.
It should reload immediately when changes are made.

```shell
$ mix deps.get
$ iex --name blog@127.0.0.1 -S mix phx.server
```

## Deploying

This blog is deployed using [Fly](https://fly.io).
When changes are ready to be published, make sure [you have installed flyctl](https://fly.io/docs/hands-on/installing/) and then run `fly deploy` in the home directory.
If you are on an M1 mac there may be some architecture issues, so you need to run `fly deploy --remote-only` to build the docker image on a remote host.

## Interacting With Production

There are two easy ways to connect to the production instance of this application.
You can use `fly ssh console` to easily jump onto the shell of the production instance.
This is handy for checking out files etc, and you can also quickly jump into the app with `/app/blog/bin/blog remote` to jump into an IEx shell connected to the running application.

We also have a helper `./remote_connect.sh` which can connect a local vm to the production instance so you can use things like `:observer.start()` to introspect the production instance.

## Showoff

This application also hosts the showoff tool which is a tool to learn about programming and SVG.
In order to access it you need to make a request with a hostname prefixed by `showoff.*`.
The easiest way to do this in development is to add an entry to `/etc/hosts` that points `showoff.local` to `127.0.0.1`.
Then in your browser you can go to `http://showoff.local:4001`.
