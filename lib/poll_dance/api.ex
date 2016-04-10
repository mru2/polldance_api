defmodule PollDance.Api do

  alias PollDance.UserIdPlug

  use Plug.Router
  import Plug.Conn

  plug Plug.Parsers, parsers: [:json], json_decoder: Poison
  plug UserIdPlug
  plug :match
  plug :dispatch


  # Create a new playlist
  post "/api/playlist" do
    name = conn.params["name"]
    loc = { conn.params["lat"], conn.params["lng"] }

    case PollDance.launch(name, loc) do
      {:ok, playlist_id} ->
        {:ok, snapshot} = playlist_id |> PollDance.snapshot
        send_resp(conn, 201, snapshot |> Poison.encode!)
      {:error, {:existing, id}} -> conn |> put_resp_header("location", "/api/playlist/#{id}") |> send_resp(302, "")
      {:error, :invalid_params} -> send_resp(conn, 422, "")
      _                         -> send_resp(conn, 500, "An error happened")
    end
  end

  # List playlists around me
  get "/api/playlists" do
    loc = { conn.params["lat"] |> String.to_float, conn.params["lng"] |> String.to_float }
    resp = PollDance.nearest_around(loc)
           |> Enum.map( fn {id, name, dist} -> %{id: id, name: name, dist: dist} end )
           |> Poison.encode!
    send_resp(conn, 200, resp)
  end

  # Get a playlist's info
  get "/api/playlists/:playlist_id" do
    case PollDance.snapshot(playlist_id) do
      {:ok, snapshot}      -> send_resp(conn, 200, Poison.encode!(snapshot))
      {:error, :not_found} -> send_resp(conn, 404, "")
      _                    -> send_resp(conn, 500, "An error happened")
    end
  end

  # Search for tracks
  get "/api/search" do
    query = conn.params["q"]
    case query do
      nil -> send_resp(conn, 422, "Please specify a query")
      ""  -> send_resp(conn, 422, "Please specify a query")
      q   ->
        res = PollDance.Deezer.search(q)
        send_resp(conn, 200, Poison.encode!(res))
    end
  end

  # Add a track
  post "/api/playlists/:playlist_id/tracks" do
    track = {conn.params["id"], conn.params["title"], conn.params["artist"]}
    {:ok, snapshot} = PollDance.add_track(playlist_id, UserIdPlug.get(conn), track)
    send_resp(conn, 200, Poison.encode!(snapshot))
  end

  # Vote for a track
  post "/api/playlists/:playlist_id/tracks/:track_id" do
    {:ok, snapshot} = PollDance.add_vote(playlist_id, UserIdPlug.get(conn), track_id)
    send_resp(conn, 200, Poison.encode!(snapshot))
  end

  # Pop the top track
  delete "/api/playlists/:playlist_id/tracks" do
    {:ok, track_snapshot} = PollDance.pop_top_track(playlist_id)
    send_resp(conn, 200, Poison.encode!(track_snapshot))
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
