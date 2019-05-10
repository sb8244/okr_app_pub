### BUILDER

FROM elixir:1.7.3-slim as builder

LABEL maintainer="SalesLoft"

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN apt-get update && apt-get -y install openssl locales locales-all git build-essential curl

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get install -y nodejs

# Install hex
RUN /usr/local/bin/mix local.hex --force && \
    /usr/local/bin/mix local.rebar --force && \
    /usr/local/bin/mix hex.info

WORKDIR /app

COPY mix.exs mix.lock ./
RUN MIX_ENV='prod' mix deps.get --only prod
RUN MIX_ENV='prod' mix deps.compile

COPY assets/package.json assets/package-lock.json ./assets/
RUN cd assets && npm install

COPY . .

RUN cd assets && npm run deploy
RUN MIX_ENV='prod' mix phx.digest
RUN MIX_ENV='prod' mix release --env=prod

### RUNNER

FROM elixir:1.7.3-slim

WORKDIR /app

COPY --from=builder /app/releases/okr_app ./
COPY --from=builder /app/priv/repo/migrations/ ./priv/repo/migrations/
COPY --from=builder /app/priv/static/ ./priv/static/
COPY --from=builder /app/rel/vm.args .

ENTRYPOINT ["./bin/okr_app"]
CMD ["foreground"]
