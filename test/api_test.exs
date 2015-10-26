defmodule ApiTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts PollDance.Api.init([])

  test "posting a new playlist" do
    assert_request(
      {
        :post,
        "/api/playlist",
        %{
          "lat"  => 51.5033630,
          "lng"  => -0.1276250,
          "name" => "Test Playlist"
        }
      },
      {
        201,
        %{
          "id"     => 670253020,
          "name"   => "Test Playlist",
          "lat"    => 51.5033630,
          "lng"    => -0.1276250,
          "tracks" => []
        }
      }
    )
  end

  test "fetching a playlist snapshot" do

  end

  defp assert_request({method, path, body}, {code, response}) do
    conn = conn(method, path, Poison.encode!(body)) |> put_req_header("content-type", "application/json")
    conn = PollDance.Api.call(conn, @opts)
    assert conn.status == code
    assert Poison.decode!(conn.resp_body) == response
  end

end
