defmodule PollDance do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = String.to_integer(System.get_env("PORT"))
    IO.puts "Starting app on port #{port}"

    children = [
      # API
      Plug.Adapters.Cowboy.child_spec(:http, PollDance.Api, [], port: port)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PollDance.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
