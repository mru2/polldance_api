defmodule PollDance.Processes.PlaylistStore do
  alias PollDance.Structs.Playlist

  use ExActor.GenServer

  defstart start_link(name, loc), gen_server_opts: :runtime, do: initial_state(Playlist.new(name, loc))

  # Name and loc are used by the registry
  defcall get_info, state: playlist do
    reply({playlist.name, playlist.loc})
  end

end
