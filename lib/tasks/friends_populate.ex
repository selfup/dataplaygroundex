defmodule Mix.Tasks.Friends.Populate do
  def run(_) do
    :ok = Mix.Task.run("ecto.drop")
    :ok = Mix.Task.run("ecto.create")
    :ok = Mix.Task.run("ecto.migrate")
    :ok = Mix.Task.run("app.start")

    true = Friends.run()
  end
end
