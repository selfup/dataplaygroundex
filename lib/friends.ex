defmodule Friends do
  @moduledoc """
  Documentation for Friends.
  """

  def populate_pg() do
    0..5_000
    |> Enum.map(fn age ->
      %Friends.Person{first_name: "Billy", last_name: "Joe", age: age}
    end)
    |> Task.async_stream(
      fn person ->
        Friends.Repo.insert(person)
      end,
      max_concurrency: 900
    )
    |> Enum.map(fn {:ok, val} -> val end)
  end

  def populate_redis() do
    people =
      0..10_000
      |> Enum.map(fn age ->
        %Friends.Person{first_name: "Billy", last_name: "Joe", age: age}
      end)

    people
    |> Task.async_stream(
      fn person ->
        Redix.command(:redix, ["SET", to_string(person.age), "foo"])
      end,
      max_concurrency: 900
    )
    |> Enum.map(fn {:ok, val} -> val end)

    people
    |> Task.async_stream(
      fn person ->
        payload =
          Jason.encode!(%{
            key: person.age,
            data: %{
              first_name: person.first_name,
              last_name: person.last_name
            }
          })

        Redix.command(:redix, ["GET", to_string(person.age), payload])
      end,
      max_concurrency: 900
    )
    |> Enum.map(fn {:ok, val} -> val end)
  end

  def populate_smache_lb_api() do
    people =
      0..10_000
      |> Enum.map(fn age ->
        %Friends.Person{first_name: "Billy", last_name: "Joe", age: age}
      end)

    people
    |> Task.async_stream(fn person ->
      payload =
        Jason.encode!(%{
          key: person.age,
          data: %{
            first_name: person.first_name,
            last_name: person.last_name
          }
        })

      HTTPoison.post!(
        "http://localhost:4000/api",
        payload,
        [{"Content-Type", "application/json"}],
        hackney: [pool: :default]
      )
    end)
    |> Enum.map(fn {:ok, val} -> val.body end)

    people
    |> Task.async_stream(
      fn person ->
        HTTPoison.get!("http://localhost:4000/api/?key=" <> to_string(person.age), [],
          hackney: [pool: :default]
        )
      end,
      max_concurrency: 900
    )
    |> Enum.map(fn {:ok, val} -> val.body end)
  end

  defp rand_robin() do
    :"operator_#{:rand.uniform(16)}"
  end

  def populate_smache_rpc_distributed() do
    # spin up smache locally
    Node.connect(:smache@localhost)

    people =
      0..10_000
      |> Enum.map(fn age ->
        %Friends.Person{first_name: "Billy", last_name: "Joe", age: age}
      end)

    people
    |> Task.async_stream(fn person ->
      GenServer.call(
        {rand_robin(), :smache@localhost},
        {:put_or_post,
         {person.age,
          %{
            first_name: person.first_name,
            last_name: person.last_name
          }}}
      )
    end)
    |> Enum.map(fn {:ok, val} -> val end)

    people
    |> Task.async_stream(
      fn person ->
        GenServer.call({rand_robin(), :smache@localhost}, {:get, {person.age}})
      end,
      max_concurrency: 900
    )
    |> Enum.map(fn {:ok, val} -> val end)
  end
end
