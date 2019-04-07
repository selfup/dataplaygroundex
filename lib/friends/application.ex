defmodule Friends.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Friends.Repo,
      {Redix, name: :redix},
    ]

    {:ok, conn} = Redix.start_link(host: "0.0.0.0", port: 6379)

    opts = [strategy: :one_for_one, name: Friends.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def populate() do
    0..10_000
    |> Enum.map(fn age -> %Friends.Person{first_name: "Ryan", last_name: "Bigg", age: age} end)
    |> Enum.each(fn (person) -> 
      Friends.Repo.insert(person)
    end)
  end

  def populate_redis() do
    people = 
    0..10_000
    |> Enum.map(fn age -> 
      %Friends.Person{first_name: "Ryan", last_name: "Bigg", age: age}
    end)
    
    people
    |> Enum.each(fn (person) ->
      Redix.command(:redix, ["SET", to_string(person.age), "foo"])
    end)

    people
    |> Enum.each(fn (person) ->
      Redix.command(:redix, ["GET", to_string(person.age), "foo"])
    end)
  end
end
