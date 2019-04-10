# Friends

1. Postgres
1. Redis

```bash
# in a shell
docker-compose up

# in another shell
mix friends.populate
```

### Task.async_stream/3

The old school way:

```elixir
defp populate_pg() do
  populate_redis()
  |> Enum.map(fn person -> Task.async(fn -> redis_get(person) end) end)
  |> Enum.map(fn task -> pg_insert(Task.await(task)) end)
  |> length() == @length
end

# takes about 20 seconds
```

The new way:

```elixir
defp populate_pg() do
  populate_redis()
  |> Task.async_stream(fn person -> redis_get(person) end)
  |> Task.async_stream(fn {:ok, person} -> pg_insert(person) end)
  |> Enum.map(fn {:ok, val} -> val end)
  |> length() == @length
end

# takes about 8 seconds
```
