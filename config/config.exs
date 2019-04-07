use Mix.Config

config :friends, Friends.Repo,
  database: "friends_repo",
  username: "postgres",
  password: "postgres",
  hostname: "0.0.0.0"

config :friends, ecto_repos: [Friends.Repo]
