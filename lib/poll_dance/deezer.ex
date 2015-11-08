defmodule PollDance.Deezer do

  alias PollDance.Track

  @base_uri "http://api.deezer.com"

  def search(query) do
    http = HTTPoison.get! "#{@base_uri}/search?q=#{query}"
    res = Poison.decode! http.body
    res["data"]
    |> Enum.map(&to_track/1)
  end

  defp to_track(payload) do
    Track.new("dz:#{payload["id"]}", payload["title"], payload["artist"]["name"])
  end

end
