defmodule PollDance do
  use Application

  alias PollDance.Launcher
  alias PollDance.PlaylistProcess
  alias PollDance.PlaylistsSupervisor
  alias PollDance.GeoSearch

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = System.get_env("PORT") |> String.to_integer()
    IO.puts "Starting app on port #{port}"

    children = [
      # Playlists
      worker(PlaylistsSupervisor, [[name: :playlists_supervisor]]),
      # Geo Search
      worker(GeoSearch, [[name: :geo_search]]),
      # Launcher
      worker(Launcher, [[name: :launcher]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PollDance.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # GLobal helper methods, for console control and tests
  def launch(name, loc) do
    :launcher |> Launcher.launch(name, loc)
  end

  def nearest_around(loc) do
    :geo_search |> GeoSearch.nearest_around(loc)
  end

  def snapshot(playlist_id) do
    pid = PlaylistsSupervisor.whereis(playlist_id)
    case pid do
      nil -> {:error, :not_found}
      pid -> {:ok, pid |> PlaylistProcess.get_snapshot}
    end
  end

  def add_track(playlist_id, user_id, track) do
    pid = PlaylistsSupervisor.whereis(playlist_id)
    case pid do
      nil -> {:error, :not_found}
      pid ->
        pid |> PlaylistProcess.add_track(user_id, track)
        {:ok, pid |> PlaylistProcess.get_snapshot}
    end
  end

  def add_vote(playlist_id, user_id, track_id) do
    pid = PlaylistsSupervisor.whereis(playlist_id)
    case pid do
      nil -> {:error, :not_found}
      pid ->
        pid |> PlaylistProcess.add_vote(user_id, track_id)
        {:ok, pid |> PlaylistProcess.get_snapshot}
    end
  end

  def pop_top_track(playlist_id) do
    pid = PlaylistsSupervisor.whereis(playlist_id)
    case pid do
      nil -> {:error, :not_found}
      pid ->
        track = pid |> PlaylistProcess.pop
        case track do
          nil -> {:error, :no_track_to_pop}
          _   -> {:ok, PollDance.Track.snapshot(track)}
        end
    end
  end
end
