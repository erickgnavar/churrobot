use Mix.Config

config :logger, :console, metadata: [:request_id]

config :churrobot, handle: "@churrobot"
