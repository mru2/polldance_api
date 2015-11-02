# Actual endpoints implementation. To be called in the console and from the API
defmodule PollDance.Actions.Launch do

  alias PollDance.Structs.Playlist
  alias PollDance.Processes.GeoStore
  alias PollDance.Processes.PlaylistsSupervisor

  use Pipe

  # Pipeline, returns a fully loaded playlist struct
  def run(name, loc) do
    pipe_matching res, {:ok, res},
      build_playlist(name)
      |> generate_uid
      |> check_name_unicity(loc)
      |> check_id_unicity
      |> launch_process
      |> store_location(loc)
  end

  # Build a playlist
  defp build_playlist(name)
    when is_bitstring(name)
    and  byte_size(name) > 0
    do
    {:ok, %Playlist{name: name}}
  end

  defp build_playlist(_name, _loc), do: {:error, :invalid_params}

  # Generate its uid
  defp generate_uid(%Playlist{name: name} = playlist) do
    id = :erlang.crc32(name)
    {:ok, %Playlist{playlist | id: id}}
  end

  # Check name / id unicity
  defp check_name_unicity(%Playlist{name: name} = playlist, loc) do
    case GeoStore.find_by_name(:geo_store, name, loc) do
      nil -> {:ok, playlist}
      id  -> {:error, {:existing, id}}
    end
  end

  defp check_id_unicity(%Playlist{id: _id} = playlist) do
    {:ok, playlist}
  end

  # Launch a new playlist process
  defp launch_process(%Playlist{} = playlist) do
    {:ok, playlist_pid} = :playlists |> PlaylistsSupervisor.start_playlist
    {:ok, %Playlist{playlist | pid: playlist_pid}}
  end

  # Store playlist location for search
  defp store_location(%Playlist{} = playlist, {lat, lng} = loc)
    when is_float(lat)
    and  is_float(lng)
    do
    :geo_store |> GeoStore.store(playlist.name, loc, playlist.id)
    {:ok, playlist}
  end

end
