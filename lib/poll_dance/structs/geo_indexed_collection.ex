defmodule PollDance.Structs.GeoIndexedCollection do

  alias PollDance.Utils.Haversine

  def new do
    # Handled right now with a single collection
    # Could be useful as a double mapping
    []
  end

  def add(collection, {id, {lat, lng}, item}) do
    [{id, {lat, lng}, item} | collection]
  end

  # Returns nil or a tuple {id, loc, item}
  def find(collection, id) do
    collection
    |> Enum.find( fn {i_id, _loc, _item} -> i_id == id end )
  end

  # Returns tuples of {{id, loc, item}, dist}, ordered from near to far
  def around(collection, center, radius \\ 1_000) do
    collection
    |> Enum.map( fn item = {_, loc, _} -> {item, Haversine.distance_between(center, loc)} end )
    |> Enum.filter( fn {_item, dist} -> ( dist <= radius ) end )
    |> Enum.sort_by( fn {_item, dist} -> dist end )
  end

  # Remove with an id
  def remove(collection, id) do
    collection
    |> Enum.filter( fn {i_id, _loc, _item} -> i_id == id end )
  end

  # Remove an item with a filter function
  def remove_item(collection, filter) do
    collection
    |> Enum.filter( fn {_id, _loc, item} -> !filter.(item) end )
  end

end
