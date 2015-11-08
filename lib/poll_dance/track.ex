# Track structure
defmodule PollDance.Track do
  defstruct id: nil, artist: '', title: '', votes: %{}

  alias PollDance.Scoring

  def new(id, title, artist) do
    %__MODULE__{id: id, title: title, artist: artist}
  end

  def snapshot(track) do
    %{
      id: track.id,
      title: track.title,
      artist: track.artist
    }
  end

  def score(track, now \\ :os.timestamps), do: track.votes |> Map.values |> Scoring.score(now)

end
