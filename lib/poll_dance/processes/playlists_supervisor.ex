# Supervises the tracks stores, with live launch / removal
defmodule PollDance.Processes.PlaylistsSupervisor do

  alias PollDance.Processes.PlaylistStore

  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  def start_playlist(supervisor, name, loc, id) do
    Supervisor.start_child(supervisor, [name, loc, [name: {:via, :playlists_registry, id}]])
  end

  def init([]) do
    children = [
      worker(PlaylistStore, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
