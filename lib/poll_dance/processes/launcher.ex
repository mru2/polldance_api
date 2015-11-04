# In a separate process, in order to enforce race conditions on validations
defmodule PollDance.Processes.Launcher do

  alias PollDance.Processes.PlaylistsRegistry
  alias PollDance.Processes.PlaylistsSupervisor

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, name: :launcher)
  end

  def launch(name, loc = {lat, lng})
    when is_bitstring(name)
    and  byte_size(name) > 0
    and  is_float(lat) > 0
    and  is_float(lng) > 0
    do
    GenServer.call(:launcher, {:launch, name, loc})
  end

  def launch(pid, _, _), do: {:error, :invalid_params}

  # Returns {:ok, id) or {:error, reason}
  def handle_call({:launch, name, loc}, _, _) do
    case :playlists_registry |> PlaylistsRegistry.name_available?(name, loc) do
      {:no, id} -> {:error, {:existing, id}}
      :yes ->
        id = generate_uid

        # Launch the process (automatically registered by the supervisor)
        {:ok, playlist_pid} = :playlists |> PlaylistsSupervisor.start_playlist(name, loc, id)

        # Return the id
        id
    end
  end

  defp generate_uid do
    UUID.uuid1()
  end

end
