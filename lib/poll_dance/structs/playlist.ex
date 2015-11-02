# Represent a launched playlist
defmodule PollDance.Structs.Playlist do
  defstruct id: nil, name: nil, tracks: %{}, pid: nil

  alias PollDance.Structs.Track

  # Snapshot for a user
  def snapshot(playlist) do
    now = :os.timestamp
    Poison.encode! %{
      id: playlist.id,
      name: playlist.name,
      tracks: playlist.tracks
              |> Map.values
              # Higher score is better
              |> Enum.sort_by( fn track -> -Track.score(track, now) end )
              |> Enum.map( fn track -> Track.snapshot(track, now) end )
    }
  end
end
