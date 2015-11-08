# In a separate process, in order to enforce race conditions on validations
defmodule PollDance.Launcher do

  alias PollDance.GeoSearch
  alias PollDance.PlaylistsSupervisor

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def launch(pid, name, loc = {lat, lng})
    when is_bitstring(name)
    and  byte_size(name) > 0
    and  is_float(lat) > 0
    and  is_float(lng) > 0
    do
    GenServer.call(pid, {:launch, name, loc})
  end


  def launch(pid, _, _), do: {:error, :invalid_params}

  # Returns {:ok, id) or {:error, reason}
  def handle_call({:launch, name, loc}, _, _) do
    case :geo_search |> GeoSearch.name_available?(name, loc) do
      {:no, id} -> {:reply, {:error, {:existing, id}}, nil}
      :yes ->
        id = generate_uid

        # Launch the process (automatically registered by the supervisor)
        {:ok, _playlist_pid} = :playlists_supervisor |> PlaylistsSupervisor.start_playlist({id, name})

        # Register the playlist in the geo store
        :geo_search |> GeoSearch.register({id, name}, loc)

        # Return the id
        {:reply, {:ok, id}, nil}
    end
  end

  defp generate_uid do
    UUID.uuid1()
  end

end
