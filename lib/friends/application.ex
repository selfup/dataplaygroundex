defmodule Friends.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Friends.Repo,
      {Redix, host: "0.0.0.0", port: 6379, name: :redix}
    ]

    opts = [strategy: :one_for_one, name: Friends.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
