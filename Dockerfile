FROM hexpm/elixir:1.10.1-erlang-22.2.6-alpine-3.11.3 as build

# install build dependencies
RUN apk add --update git build-base nodejs npm yarn python

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# build assets
COPY assets assets
COPY priv priv
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

# build project
COPY lib lib
COPY _posts _posts
RUN mix compile

# build release (uncomment COPY if rel/ exists)
# COPY rel rel
RUN mix release

# prepare release image
# make sure to use the same alpine verion as specified in the build image
FROM alpine:3.11.3 AS app
RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

COPY --from=build /app/_build/prod/rel/blog ./
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app