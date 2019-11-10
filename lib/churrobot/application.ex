defmodule Churrobot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Churrobot.Worker.start_link(arg)
      # {Churrobot.Worker, arg}
      # {Plug.Cowboy, scheme: :http, plug: Churrobot.BotPlug, options: [port: 10000]}
      {Plug.Cowboy, scheme: :http, plug: Churrobot.Router, options: [port: 10000]},
      {Churrobot.OffersManager, %{}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Churrobot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
