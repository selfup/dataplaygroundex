defmodule Mix.Tasks.Friends.Populate do
  def run(_) do
    :ok = Mix.Task.run("ecto.drop")
    :ok = Mix.Task.run("ecto.create")
    :ok = Mix.Task.run("ecto.migrate")
    :ok = Mix.Task.run("app.start")

    micro_seconds =
      :timer.tc(fn -> true = Friends.run() end)
      |> elem(0)

    milli_seconds = micro_seconds / 1000

    IO.puts("Task took #{milli_seconds}ms to run!")
  end
end
