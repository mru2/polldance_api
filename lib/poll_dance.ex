defmodule PollDance do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = System.get_env("PORT") |> String.to_integer()
    IO.puts "Starting app on port #{port}"

    children = [
      # API
      Plug.Adapters.Cowboy.child_spec(:http, PollDance.Api, [], port: port),
      # Playlists
      worker(PollDance.PlaylistsSupervisor, [[name: :playlists_supervisor]]),
      # Geo Search
      worker(PollDance.GeoSearch, [[name: :geo_search]]),
      # Launcher
      worker(PollDance.Launcher, [[name: :launcher]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PollDance.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # GLobal helper methods, for console control and tests
  def launch(name, loc) do
    :launcher |> PollDance.Launcher.launch(name, loc)
  end

  def nearest_around(loc) do
    :geo_search |> PollDance.GeoSearch.nearest_around(loc)
  end

  def snapshot(playlist_id) do
    pid = PollDance.PlaylistsSupervisor.whereis(playlist_id)
    case pid do
      nil -> {:error, :not_found}
      pid -> {:ok, pid |> PollDance.Playlist.get_snapshot}
    end
  end

  def add_track(playlist_id, user_id, track) do
    pid = PollDance.PlaylistsSupervisor.whereis(playlist_id)
    case pid do
      nil -> {:error, :not_found}
      pid ->
        pid |> PollDance.Playlist.add_track(user_id, track)
        {:ok, pid |> PollDance.Playlist.get_snapshot}
    end
  end

  def add_vote(playlist_id, user_id, track_id) do
    pid = PollDance.PlaylistsSupervisor.whereis(playlist_id)
    case pid do
      nil -> {:error, :not_found}
      pid ->
        pid |> PollDance.Playlist.add_vote(user_id, track_id)
        {:ok, pid |> PollDance.Playlist.get_snapshot}
    end
  end

  def pop_top_track(playlist_id) do
    pid = PollDance.PlaylistsSupervisor.whereis(playlist_id)
    case pid do
      nil -> {:error, :not_found}
      pid ->
        track = pid |> PollDance.Playlist.pop
        case track do
          nil -> {:error, :no_track_to_pop}
          _   -> {:ok, PollDance.Track.snapshot(track)}
        end
    end
  end
end
