defmodule PollDance.Api do

  use Plug.Router
  import Plug.Conn

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "hello world")
  end

  get "/api/tracks" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, ~s({"hello":"world"}))
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

end
