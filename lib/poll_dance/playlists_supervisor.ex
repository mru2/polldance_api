# Supervises the playlist processes
# Also handle their launch
defmodule PollDance.PlaylistsSupervisor do

  alias PollDance.PlaylistProcess

  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  def start_playlist(supervisor, {id, name}) do
    Supervisor.start_child(
      supervisor,
      [
        id,
        name,
        [name: process_name(id)]
      ]
    )
  end

  def init([]) do
    children = [
      worker(PlaylistProcess, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end


  # Process naming
  def whereis(id) do
    id |> process_name |> Process.whereis
  end

  def process_name(id) do
    "playlist:#{id}" |> String.to_atom
  end

end
