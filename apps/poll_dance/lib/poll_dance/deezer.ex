defmodule PollDance.Deezer do

  alias PollDance.Track

  @base_uri "http://api.deezer.com"

  def search(query) do
    http = HTTPoison.get! "#{@base_uri}/search?q=#{query}"
    res = Poison.decode! http.body
    res["data"]
    |> Enum.map(&serialize_track/1)
  end

  defp serialize_track(payload) do
    %{
      id: "dz:#{payload["id"]}",
      title: payload["title"],
      artist: payload["artist"]["name"]
    }
  end

end
