# Friends

```bash
docker-compose up
mix exto.drop && mix ecto.create && mix ecto.migrate
iex -S mix
```

```elixir
ok = :timer.tc(fn -> Friends.populate_redis end) |> elem(0); ok / 1000
ok = :timer.tc(fn -> Friends.populate_pg end) |> elem(0); ok / 1000
```
