# Friends

1. Postgres
1. Redis
1. [Smache](https://github.com/selfup/smache)

```bash
docker-compose up
mix ecto.drop && mix ecto.create && mix ecto.migrate && iex -S mix
```

```elixir
ok = :timer.tc(fn -> Friends.populate_redis end) |> elem(0); ok / 1000
ok = :timer.tc(fn -> Friends.populate_pg end) |> elem(0); ok / 1000
ok = :timer.tc(fn -> Friends.populate_smache_lb_api end) |> elem(0); ok / 1000
```
