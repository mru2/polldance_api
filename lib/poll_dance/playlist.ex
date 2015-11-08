# Both the playlist structure, and the process around it
# Does it need the id, loc, name, etc ???
defmodule PollDance.Playlist do
  defstruct id: nil, name: nil, tracks: %{}, playing: nil

  alias PollDance.Track

  use ExActor.GenServer

  # Structure logic
  def new(id, name, loc) do
    %__MODULE__{id: id, name: name}
  end

  # Snapshot for a user
  def snapshot(playlist) do
    now = :os.timestamp

    playing = case playlist.playing do
      nil -> %{}
      track -> %{title: track.title, artist: track.artist}
    end

    tracks = playlist.tracks
    |> Map.values
    # Higher score is better
    |> Enum.sort_by( fn track -> -Track.score(track, now) end )
    |> Enum.map( fn track -> Track.snapshot(track, now) end )

    %{
      id: playlist.id,
      name: playlist.name,
      playing: playing,
      tracks: tracks
    }
  end

  # Process methods
  defstart start_link(id, name), gen_server_opts: :runtime do
    playlist = %__MODULE__{id: id, name: name}
    initial_state(playlist)
  end

  # Get a snapshot
  defcall get_snapshot, state: playlist, do: reply(playlist |> snapshot)

end
