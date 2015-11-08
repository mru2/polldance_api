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
    playing = case playlist.playing do
      nil -> %{}
      track -> %{title: track.title, artist: track.artist}
    end

    tracks = playlist |> sorted_tracks |> Enum.map(&Track.snapshot/1)

    %{
      id: playlist.id,
      name: playlist.name,
      playing: playing,
      tracks: tracks
    }
  end

  # Manipulation
  def add_track(%__MODULE__{tracks: tracks} = playlist, track) do
    case playlist |> Map.has_key?(track.id) do
      true -> playlist
      false -> %__MODULE__{ playlist | tracks: tracks |> Map.put(track.id, track) }
    end
  end

  def add_vote(%__MODULE__{tracks: tracks} = playlist, track_id, user_id) do
    case playlist |> Map.has_key?(track_id) do
      false -> playlist
      true  -> %__MODULE__{ playlist | tracks: tracks |> Map.update!(track_id, fn track -> track |> Track.update_vote(user_id) end) }
    end
  end

  def pop_top_track(%__MODULE__{tracks: tracks} = playlist) do
    top_track = playlist |> sorted_tracks |> Enum.take(1)
    case top_track do
      []      -> {nil, playlist}
      [track] -> {track, %__MODULE__{ playlist | tracks: tracks |> Map.delete(track.id),
                                                 playing: %{artist: track.artist, title: track.title} }}
    end
  end

  def sorted_tracks(%__MODULE__{tracks: tracks} = playlist) do
    now = :os.timestamp
    # Higher score is better
    tracks |> Map.values |> Enum.sort_by( fn track -> -Track.score(track, now) end )
  end

  # Process methods
  defstart start_link(id, name), gen_server_opts: :runtime do
    playlist = %__MODULE__{id: id, name: name}
    initial_state(playlist)
  end

  # Get a snapshot
  defcall get_snapshot, state: playlist, do: reply(playlist |> snapshot)

  # Add a track
  defcast add_track(user_id, track), state: playlist do
    playlist
    |> add_track(track)
    |> add_vote(track.id, user_id)
    |> new_state
  end

  # Vote for a track
  defcast add_vote(user_id, track_id), state: playlist, do: playlist |> add_vote(track_id, user_id) |> new_state

  # Pop the top track
  defcall pop, state: playlist do
    {track, new_playlist} = playlist |> pop_top_track
    set_and_reply(new_playlist, track)
  end
end
