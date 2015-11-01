# Represent a launched playlist
defmodule PollDance.Structs.Playlist do
  defstruct id: nil, name: nil, loc: {0, 0}, tracks: %{}, pid: nil

  alias PollDance.Structs.Track

  # Snapshot for a user
  def snapshot(playlist) do
    now = :os.timestamp
    {lat, lng} = playlist.loc
    Poison.encode! %{
      id: playlist.id,
      name: playlist.name,
      lat: lat,
      lng: lng,
      tracks: playlist.tracks
              |> Map.values
              # Higher score is better
              |> Enum.sort_by( fn track -> -Track.score(track, now) end )
              |> Enum.map( fn track -> Track.snapshot(track, now) end )
    }
  end
end
