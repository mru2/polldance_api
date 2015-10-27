defmodule PollDance.Processes.GeoStore do
  alias PollDance.Utils.Haversine

  defmodule Point do
    defstruct name: nil, loc: {0, 0}, id: nil
  end

  use ExActor.GenServer

  @search_radius 1_000 # 1km radius

  # Use a global store for now, should be LARGELY fast enough
  defstart start_link, gen_server_opts: :runtime, do: initial_state([])

  # Find a playlist by its name around a location (for duplicates check)
  # Returns the playlist id or nil
  defcall find_by_name(name, loc), state: points do
    found = points
    |> around(loc)
    |> Enum.find( fn {%Point{name: pname}, _dist} -> pname == name end )

    case found do
      nil -> reply(nil)
      {point, _dist} -> reply(point.id)
    end
  end

  # Store a new playlist point
  defcast store(name, loc, id, pid), state: points do
    point = %Point{name: name, loc: loc, id: id}
    new_state([point | points])
  end

  # Select all the points around a location, and augment them with their distance
  defp around(points, loc) do
    points
    |> Enum.map( fn point -> {point, Haversine.distance_between(point.loc, loc)} end )
    |> Enum.filter( fn {_point, dist} -> ( dist <= @search_radius ) end )
  end

end
