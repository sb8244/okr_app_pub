# OkrApp

This application is internally used at SalesLoft for OKR tracking. It has been open sourced (as a snapshot with
no git history) in order to write about some different patterns I explored while writing it.

I don't expect the runnable project to be useful to you. The code / tests may bring value as a reference of
different patterns.

## Get started

To start your Phoenix server:

  1. `mix deps.get`
  2. `mix ecto.create && mix ecto.migrate`
  3. `cd assets && npm install && cd ..`
  4. `mix phx.server`

Now you can visit [`http://localhost:6006`](http://localhost:6006) from your browser.

## Seeds

You can seed some starter data. If you want to use an Okta login, you'll need to set it up properly. It's recommended
to fake the login locally for this reason.

```
mix ecto.reset && mix run priv/seed.exs
```

## Fake Login

You can fake login (in dev env only), by hitting the following URL:

```
http://localhost:6006/force_login?user_name=steve.bussey%2Bdev@salesloft.com
```

You can change the user_name parameter to anything in the `priv/seed.exs` file.
