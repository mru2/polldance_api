defmodule PollDance.Playlist do

  alias PollDance.Playlist
  alias PollDance.Scoring

  # Structure
  defstruct id: nil, name: nil, tracks: %{}, playing: nil

  # Track definition
  defmodule Track do

    # Structure
    defstruct id: nil, artist: '', title: '', votes: %{}

    # Initialization
    def new(id, title, artist) do
      %Track{id: id, title: title, artist: artist}
    end

    def snapshot(track) do
      %{
        id: track.id,
        title: track.title,
        artist: track.artist
      }
    end

    def update_vote(%Track{votes: votes} = track, user_id) do
      now = :os.timestamps
      %Track{ track | votes: votes |> Map.put(user_id, now) }
    end

    def remove_vote(%Track{votes: votes} = track, user_id) do
      %Track{ track | votes: votes |> Map.delete(user_id) }
    end

    def score(track, now \\ :os.timestamps) do
      track.votes
      |> Map.values
      |> Scoring.score(now)
    end

  end

  # Initialization
  def new(id, name) do
    %Playlist{id: id, name: name}
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

  # Ordered tracks
  def sorted_tracks(%Playlist{tracks: tracks}) do
    now = :os.timestamp
    # Higher score is better
    tracks
    |> Map.values
    |> Enum.sort_by( fn track -> -Track.score(track, now) end )
  end

  # Manipulation
  def add_track(%Playlist{tracks: tracks} = playlist, {track_id, track_title, track_artist}) do
    track = Track.new(track_id, track_title, track_artist)
    case tracks |> Map.has_key?(track.id) do
      true -> playlist
      false -> %Playlist{ playlist | tracks: tracks |> Map.put(track.id, track) }
    end
  end

  def add_vote(%Playlist{tracks: tracks} = playlist, track_id, user_id) do
    case tracks |> Map.has_key?(track_id) do
      false -> playlist
      true  -> %Playlist{ playlist | tracks: tracks |> Map.update!(track_id, fn track -> track |> Track.update_vote(user_id) end) }
    end
  end

  def remove_vote(%Playlist{tracks: tracks} = playlist, track_id, user_id) do
    case tracks |> Map.has_key?(track_id) do
      false -> playlist
      true  -> %Playlist{ playlist | tracks: tracks |> Map.update!(track_id, fn track -> track |> Track.remove_vote(user_id) end) }
    end
  end

  def pop_top_track(%Playlist{tracks: tracks} = playlist) do
    top_track = playlist |> sorted_tracks |> Enum.take(1)
    case top_track do
      []      -> {nil, playlist}
      [track] -> {track, %Playlist{ playlist | tracks: tracks |> Map.delete(track.id),
                                               playing: %{artist: track.artist, title: track.title} }}
    end
  end

end
