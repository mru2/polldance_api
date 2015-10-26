defmodule PollDance.Playlist do
  defstruct id: nil, name: nil, location: {0, 0}, tracks: []

  def new(name, {lat, lng}) do
    id = :erlang.crc32(name)
    %__MODULE__{id: id, name: name, location: {lat, lng}}
  end

end
