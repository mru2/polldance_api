# Playlists geo search store
defmodule PollDance.GeoSearch do

  # Indexed items are name/id structs for the playlists
  defmodule Item do
    defstruct name: nil, id: nil
  end

  alias PollDance.GeoCollection

  use ExActor.GenServer

  @search_radius 1_000 # 1km radius

  # Use a global store for now, should be LARGELY fast enough
  defstart start_link, gen_server_opts: :runtime, do: initial_state( GeoCollection.new )

  # Register a new playlist
  defcast register({id, name}, loc), state: store do
    item = %Item{name: name, id: id}
    new_state(store |> GeoCollection.add({loc, item}))
  end

  # Unregister a playlist
  defcast unregister(id), state: store do
    new_state(store |> GeoCollection.remove_item( fn item -> item.id == id end ))
  end

  # Check if a name is already used
  defcall name_available?(name, center), state: store do
    case store
         |> GeoCollection.around(center, @search_radius * 2)
         |> Enum.find( fn {item, _dist} -> item.name == name end )
    do
      nil -> reply(:yes)
      {item, _dist} -> reply({:no, item.id})
    end
  end

  # Find all playlists around a point
  # Returns tuples {id, name, dist}
  defcall nearest_around(center, limit \\ 10), state: store do
    store
    |> GeoCollection.around(center, @search_radius)
    |> Enum.take(limit)
    |> Enum.map( fn {item, dist} -> {item.id, item.name, dist} end )
    |> reply
  end
end
