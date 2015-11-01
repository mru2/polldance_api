defmodule PollDance.Api do

  alias PollDance.Structs.Playlist

  use Plug.Router
  import Plug.Conn

  plug Plug.Parsers, parsers: [:json], json_decoder: Poison
  plug Plug.Session, store: :cookie,
                     key: "_polldance_session",
                     encryption_salt: "e8514e1a77f13fa5ca0856dbf7ce1806",
                     signing_salt: "2442a8a0fd83e5082eac2ca78beea10a",
                     key_length: 64
  plug :match
  plug :dispatch


  # Create a new playlist
  post "/api/playlist" do
    name = conn.params["name"]
    loc = { conn.params["lat"], conn.params["lng"] }

    case PollDance.launch(name, loc) do
      {:ok, playlist}           -> send_resp(conn, 201, Playlist.snapshot(playlist))
      {:error, {:existing, id}} -> conn |> put_resp_header("location", "/api/playlist/#{id}") |> send_resp(302, "")
      {:error, :invalid_params} -> send_resp(conn, 422, "")
      _                         -> send_resp(conn, 500, "An error happened")
    end
  end

  # List playlists around me
  get "/api/playlists" do
    loc = { conn.params["lat"] |> String.to_float, conn.params["lng"] |> String.to_float }
    results = :geo_store |> PollDance.Processes.GeoStore.nearest_around(loc)
    send_resp(conn, 200, Poison.encode!(results))
  end

  # Get a playlist's info
  get "/api/playlists/:id" do
    case PollDance.get_playlist(conn.params["integer"]) do
      {:ok, playlist}      -> send_resp(conn, 200, Playlist.snapshot(playlist))
      {:error, :not_found} -> send_resp(conn, 404, "")
      _                    -> send_resp(conn, 500, "An error happened")
    end
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
