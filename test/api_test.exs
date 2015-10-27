defmodule ApiTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts PollDance.Api.init([])

  test "user story" do
    assert_step(
      "I should be able to post a new playlist",
      {:post, "/api/playlist", %{"lat" => 51.5033630, "lng" => -0.1276250, "name" => "Test Playlist"}},
      %{
        status: 201,
        json: %{
          "id"     => 670253020,
          "name"   => "Test Playlist",
          "lat"    => 51.5033630,
          "lng"    => -0.1276250,
          "tracks" => []
        }
      }
    )

    assert_step(
      "I should not be able to post again with the same name",
      {:post, "/api/playlist", %{"lat" => 51.5034, "lng" => -0.1277, "name" => "Test Playlist"}},
      %{
        status: 302,
        location: "/api/playlist/670253020"
      }
    )

    assert_step(
      "I should be able to post with a different name",
      {:post, "/api/playlist", %{"lat" => 51.5034, "lng" => -0.1277, "name" => "Another Test Playlist"}},
      %{ status: 201 }
    )

    assert_step(
      "I should be able to use the same name if further",
      {:post, "/api/playlist", %{"lat" => 53.0, "lng" => -2.0, "name" => "Test Playlist"}},
      %{ status: 201 }
    )
  end

  defp assert_step(message, {method, path, body}, resp) do
    IO.puts message
    conn = conn(method, path, Poison.encode!(body)) |> put_req_header("content-type", "application/json")
    conn = PollDance.Api.call(conn, @opts)

    if expected_status = Map.get(resp, :status), do: assert conn.status == expected_status
    if expected_location = Map.get(resp, :location), do: assert hd(get_resp_header(conn, "location")) == expected_location
    if expected_json = Map.get(resp, :json), do: assert Poison.decode!(conn.resp_body) == expected_json
  end

end
