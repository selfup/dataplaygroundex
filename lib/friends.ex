defmodule Friends do
  @moduledoc """
  Documentation for Friends.
  """

  @length 5_000

  def run() do
    populate_pg()
  end

  defp populate_pg() do
    true =
      populate_redis()
      |> Task.async_stream(fn person -> redis_get(person) end)
      |> Task.async_stream(fn {:ok, person} -> pg_insert(person) end)
      |> Enum.map(fn {:ok, val} -> val end)
      |> length() == @length
  end

  defp pg_insert(person) do
    decoded = Jason.decode!(person)

    payload = %Friends.Person{
      first_name: decoded["first_name"],
      last_name: decoded["last_name"],
      age: decoded["age"]
    }

    Friends.Repo.insert(payload)
  end

  defp populate_redis() do
    1..@length
    |> Enum.map(fn age -> create_person(age) end)
    |> Task.async_stream(fn person -> redis_set(person) end)
    |> Enum.map(fn {:ok, val} -> val end)
  end

  defp create_person(age) do
    %Friends.Person{first_name: "Billy", last_name: "Joe", age: age}
  end

  defp redis_get(person) do
    case Redix.command(:redix, ["GET", to_string(person.age)]) do
      {:ok, result} -> result
    end
  end

  defp redis_set(person) do
    payload =
      Jason.encode!(%{
        age: person.age,
        data: %{
          first_name: person.first_name,
          last_name: person.last_name
        }
      })

    Redix.command(:redix, ["SET", to_string(person.age), payload])

    person
  end
end
