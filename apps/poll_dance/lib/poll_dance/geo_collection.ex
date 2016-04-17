defmodule PollDance.GeoCollection do

  @earth_radius 6_371_000
  @pi :math.pi

  def new do
    # Handled right now with a single collection
    # Could be useful as a double mapping
    []
  end

  def add(collection, {{lat, lng}, item}) do
    [{{lat, lng}, item} | collection]
  end

  # Returns tuples of {item, dist}, ordered from near to far
  def around(collection, center, radius \\ 1_000) do
    collection
    |> Enum.map( fn {loc, item} -> {item, distance_between(center, loc)} end )
    |> Enum.filter( fn {_item, dist} -> ( dist <= radius ) end )
    |> Enum.sort_by( fn {_item, dist} -> dist end )
  end

  # Remove an item with a filter function
  def remove_item(collection, filter) do
    collection
    |> Enum.filter( fn {loc, item} -> !filter.(item) end )
  end

  # Compute the distance between 2 points, using the haversine formula
  defp distance_between({lat1, lng1}, {lat2, lng2}) do
    fo_1 = degrees_to_radians(lat1)
    fo_2 = degrees_to_radians(lat2)
    diff_fo = degrees_to_radians(lat2 - lat1)
    diff_la = degrees_to_radians(lng2 - lng1)
    a = :math.sin(diff_fo / 2) * :math.sin(diff_fo / 2) + :math.cos(fo_1) * :math.cos(fo_2) * :math.sin(diff_la / 2) * :math.sin(diff_la / 2)
    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    @earth_radius * c
  end

  # Deg / Rad conversion
  defp degrees_to_radians(degrees) do
    normalize_degrees(degrees) * @pi / 180
  end

  # Deg normalization
  defp normalize_degrees(degrees) when degrees < -180 do
    normalize_degrees(degrees + 2 * 180)
  end
  defp normalize_degrees(degrees) when degrees > 180 do
    normalize_degrees(degrees - 2 * 180)
  end
  defp normalize_degrees(degrees) do
    degrees
  end

end
