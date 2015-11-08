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

  def update_vote(%__MODULE__{votes: votes} = track, user_id) do
    now = :os.timestamps
    %__MODULE__{ track | votes: votes |> Map.put(user_id, now) }
  end

  def score(track, now \\ :os.timestamps), do: track.votes |> Map.values |> Scoring.score(now)

end
