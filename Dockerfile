FROM elixir:1.9-alpine as builder

WORKDIR /app

# Set environment variables for building the application
ENV MIX_ENV=prod \
    LANG=C.UTF-8

# Install system dependencies
RUN apk add --update git build-base

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install Mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# Compile project
COPY lib lib
COPY priv priv
RUN mix compile

# Assemble release
COPY rel rel
RUN mix release

FROM alpine:3.9

ENV MIX_ENV=prod \
    LANG=C.UTF-8

RUN apk update && apk add ncurses-libs

RUN adduser -D app

WORKDIR /home/app

COPY --from=builder /app/_build/prod/rel/event_manager .

RUN chown -R app: .

CMD ["bin/event_manager", "start"]