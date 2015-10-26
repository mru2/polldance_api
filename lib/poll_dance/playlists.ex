# Playlists global store
# TODO : decouple playlist process list (id, tracks) and actual processes from research (loc, ...)
defmodule PollDance.Playlists do

  use GenServer
  alias PollDance.Playlist

  # Client
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def launch(name, {lat, lng}) when is_bitstring(name)
                               and  byte_size(name) > 0
                               and  is_float(lat)
                               and  is_float(lng) do

    playlist = Playlist.new(name, {lat, lng})
    {:ok, playlist}
  end
end
