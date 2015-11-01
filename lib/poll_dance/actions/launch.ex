# Actual endpoints implementation. To be called in the console and from the API
defmodule PollDance.Actions.Launch do

  alias PollDance.Structs.Playlist
  alias PollDance.Processes.GeoStore
  alias PollDance.Processes.PlaylistsSupervisor

  use Pipe

  # Pipeline, returns a fully loaded playlist struct
  def run(name, loc) do
    pipe_matching res, {:ok, res},
      build_playlist(name, loc)
      |> generate_uid
      |> check_name_unicity
      |> check_id_unicity
      |> launch_process
      |> store_location
  end

  # Build a playlist
  defp build_playlist(name, {lat, lng} = loc)
    when is_bitstring(name)
    and  byte_size(name) > 0
    and  is_float(lat)
    and  is_float(lng) do
    {:ok, %Playlist{name: name, loc: loc}}
  end

  defp build_playlist(_name, _loc), do: {:error, :invalid_params}

  # Generate its uid
  defp generate_uid(%Playlist{name: name} = playlist) do
    id = :erlang.crc32(name)
    {:ok, %Playlist{playlist | id: id}}
  end

  # Check name / id unicity
  defp check_name_unicity(%Playlist{name: name, loc: loc} = playlist) do
    case GeoStore.find_by_name(:geo_store, name, loc) do
      nil -> {:ok, playlist}
      id  -> {:error, {:existing, id}}
    end
  end

  defp check_id_unicity(%Playlist{id: _id} = playlist) do
    {:ok, playlist}
  end

  # Launch a new playlist process
  defp launch_process(playlist = %Playlist{} = playlist) do
    {:ok, playlist_pid} = :playlists |> PlaylistsSupervisor.start_playlist
    {:ok, %Playlist{playlist | pid: playlist_pid}}
  end

  # Store playlist location for search
  defp store_location(playlist = %Playlist{} = playlist) do
    :geo_store |> GeoStore.store(playlist.name, playlist.loc, playlist.id, playlist.pid)
    {:ok, playlist}
  end

end
