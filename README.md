# Friends

1. Postgres
1. Redis
1. [Smache](https://github.com/selfup/smache)

```bash
docker-compose up
mix ecto.drop && mix ecto.create && mix ecto.migrate \
    && iex --sname friends@localhost --cookie wow -S mix
```

```elixir
ok = :timer.tc(fn -> Friends.populate_redis end) |> elem(0); ok / 1000
ok = :timer.tc(fn -> Friends.populate_pg end) |> elem(0); ok / 1000
ok = :timer.tc(fn -> Friends.populate_smache_lb_api end) |> elem(0); ok / 1000
```

### Task.async_stream

Postgres: **5k** records write/read -> ~1_400ms
Redis: **10k** records write/read -> ~950ms
Smache http/lb: **10k** records write/read -> ~15_000ms
Smache RPC: **10k** records write/read -> ~650ms
