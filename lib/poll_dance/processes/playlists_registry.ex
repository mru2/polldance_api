# Playlists registry with geolocalized lookup
# Internally handled by a geo indexed collection
defmodule PollDance.Processes.PlaylistsRegistry do

  defmodule Item do
    defstruct name: nil, pid: nil
  end

  alias PollDance.Structs.GeoIndexedCollection
  alias PollDance.Structs.PlaylistStore

  use ExActor.GenServer
  import Kernel, except: [send: 2]

  @search_radius 1_000 # 1km radius

  # Use a global store for now, should be LARGELY fast enough
  defstart start_link, gen_server_opts: :runtime, do: initial_state( GeoIndexedCollection.new )

  # Registry API : lookup a playlist by id
  defcall whereis_name(id), state: playlists do
    case playlists |> GeoIndexedCollection.find(id) do
      nil -> reply(:undefined)
      {_id, _loc, item} -> reply(item.pid)
    end
  end

  # Registry API : register a newly launched playlist under its id
  defcall register_name(id, pid), state: playlists do
    # Get the playlist info
    {name, loc} = pid |> PlaylistStore.get_info

    # Store the item
    case playlists |> GeoIndexedCollection.find(id) do
      nil ->
        item = %Item{name: name, pid: pid}
        new_playlists = playlists |> GeoIndexedCollection.add({id, loc, item})
        Process.monitor pid
        set_and_reply(new_playlists, :yes)
      _ ->
        # Already launched
        # Maybe update its name and/or location ?
        reply(:no)
    end
  end

  # Registry API : unregister a playlist
  defcall unregister_name(id), state: playlists do
    set_and_reply(playlists |> GeoIndexedCollection.remove(id), :yes)
  end

  # Registry API : handle a down process
  defhandleinfo {:DOWN, _, :process, pid, _}, state: playlists do
    # Remove playlist from list
    new_state(playlists |> GeoIndexedCollection.remove_item( fn item -> item.pid == pid end ))
  end

  # Registry API : forward a message
  def send(id, message) do
    case whereis_name(:playlists_registry, id) do
      :undefined -> {:badarg, {id, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  # Check name availability around a location
  defcall name_available?(name, center), state: playlists do
    case playlists
         |> GeoIndexedCollection.around(center, @search_radius * 2)
         |> Enum.find( fn {{_id, _loc, item}, _dist} -> item.name == name end )
    do
      nil -> reply(:yes)
      {{id, _loc, _item}, _dist} -> reply({:no, id})
    end
  end

  # Search : find all nearest playlists around a location
  # Return tuples {id, name, dist}
  defcall nearest_around(center, limit \\ 10), state: playlists do
    playlists
    |> GeoIndexedCollection.around(center, @search_radius)
    |> Enum.limit(limit)
    |> Enum.map( fn {{id, _loc, item}, dist} -> {id, item.name, dist} end )
    |> reply
  end

end
