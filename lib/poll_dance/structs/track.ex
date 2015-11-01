defmodule PollDance.Structs.Track do
  defstruct id: nil, kind: nil, artist: '', title: '', votes: %{}

  alias PollDance.Utils.Scoring

  def snapshot(track) do
    %{
      id: track.id,
      title: track.title,
      artist: track.artist
    }
  end

  def score(track, now \\ :os.timestamps), do: track.votes |> Map.values |> Scoring.score(now)

end
