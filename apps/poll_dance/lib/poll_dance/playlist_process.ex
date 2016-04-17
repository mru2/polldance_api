# Both the playlist structure, and the process around it
# Does it need the id, loc, name, etc ???
defmodule PollDance.PlaylistProcess do

  use ExActor.GenServer

  alias PollDance.Playlist

  # Process methods
  defstart start_link(id, name), gen_server_opts: :runtime do
    initial_state(Playlist.new(id, name))
  end

  # Get a snapshot
  defcall get_snapshot, state: playlist, do: reply(playlist |> Playlist.snapshot)

  # Add a track
  defcast add_track(user_id, track), state: playlist do
    playlist
    |> Playlist.add_track(track)
    |> Playlist.add_vote(track.id, user_id)
    |> new_state
  end

  # Vote for a track
  defcast add_vote(user_id, track_id), state: playlist, do: playlist |> Playlist.add_vote(track_id, user_id) |> new_state

  # Remove a vote
  defcast add_vote(user_id, track_id), state: playlist, do: playlist |> Playlist.remove_vote(track_id, user_id) |> new_state

  # Pop the top track
  defcall pop, state: playlist do
    {track, new_playlist} = playlist |> Playlist.pop_top_track
    set_and_reply(new_playlist, track)
  end
end
