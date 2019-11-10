defmodule Churrobot.Router do
  use Plug.Router

  alias Churrobot.BotHandler

  # plug(Plug.Logger, log: :debug)
  # plug(Plug.RequestId)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["text/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  post "/churrobot" do
    response =
      conn.body_params
      |> BotHandler.parse_message()

    send_resp(conn, 200, Jason.encode!(response))
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
