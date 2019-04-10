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

* [My micro blog post about Task.async_stream/3](https://dom.events/2019/04/07/task-async-stream-in-elixir.html)
* [Hexdocs for Task.async_stream/3](https://hexdocs.pm/elixir/Task.html#async_stream/3)

**The Map/Task/async/await way (for the redis read and postgres create):**

```elixir
defp populate_pg() do
  populate_redis()
  |> Enum.map(fn person -> Task.async(fn -> redis_get(person) end) end)
  |> Enum.map(fn task -> pg_insert(Task.await(task)) end)
  |> length() == @length
end

# On MacOS (docker ontop of a VM): takes about 20 seconds
# On Linux (direct Kernel calls): takes about 8 seconds
```

**The new way:**

```elixir
defp populate_pg() do
  populate_redis()
  |> Task.async_stream(fn person -> redis_get(person) end)
  |> Task.async_stream(fn {:ok, person} -> pg_insert(person) end)
  |> Enum.map(fn {:ok, val} -> val end)
  |> length() == @length
end

# On MacOS (docker ontop of a VM): takes about 8 seconds
# On Linux (direct Kernel calls): takes about 1.5 seconds
```
