# Supervises the tracks stores, with live launch / removal
defmodule PollDance.Processes.PlaylistsSupervisor do

  alias PollDance.Processes.VotesStore

  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def start_playlist(supervisor) do
    Supervisor.start_child(supervisor, [])
  end

  def init(:ok) do
    children = [
      worker(VotesStore, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
