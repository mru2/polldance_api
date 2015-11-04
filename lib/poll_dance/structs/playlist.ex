# Represent a launched playlist
# The internal structure handled in the playlist process
defmodule PollDance.Structs.Playlist do
  defstruct name: nil, loc: nil, tracks: %{}

  alias PollDance.Structs.Track

  def new(name, loc) do
    %__MODULE__{name: name, loc: loc}
  end

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
