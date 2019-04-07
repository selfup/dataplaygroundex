defmodule Friends do
  @moduledoc """
  Documentation for Friends.
  """

  def populate_pg() do
    0..10_000
    |> Enum.map(fn age -> 
      %Friends.Person{first_name: "Billy", last_name: "Joe", age: age}
    end)
    |> Enum.each(fn (person) -> 
      Friends.Repo.insert(person)
    end)
  end

  def populate_redis() do
    people = 
    0..10_000
    |> Enum.map(fn age -> 
      %Friends.Person{first_name: "Billy", last_name: "Joe", age: age}
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
