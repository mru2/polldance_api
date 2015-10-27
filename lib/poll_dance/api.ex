defmodule PollDance.Api do

  use Plug.Router
  import Plug.Conn

  plug Plug.Parsers, parsers: [:json], json_decoder: Poison
  plug :match
  plug :dispatch

  post "/api/playlist" do
    name = conn.params["name"]
    loc = { conn.params["lat"], conn.params["lng"] }

    case PollDance.launch(name, loc) do
      {:ok, playlist}           -> send_resp(conn, 201, snapshot(playlist))
      {:error, {:existing, id}} -> conn |> put_resp_header("location", "/api/playlist/#{id}") |> send_resp(302, "")
      {:error, :invalid_params} -> send_resp(conn, 422, "")
      _                         -> send_resp(conn, 500, "An error happened")
    end
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp snapshot(playlist) do
    {lat, lng} = playlist.loc
    Poison.encode! %{
      id: playlist.id,
      name: playlist.name,
      lat: lat,
      lng: lng,
      tracks: playlist.tracks
    }
  end

end
