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
      }
    )

    [{playlist_id, "Test Playlist", _dist} | _] = PollDance.nearest_around({51.5033630, -0.1276250})

    assert_step(
      "I should not be able to post again with the same name",
      {:post, "/api/playlist", %{"lat" => 51.505, "lng" => -0.1280, "name" => "Test Playlist"}},
      %{
        status: 302,
        location: "/api/playlist/#{playlist_id}"
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

    assert_step(
      "I should be able to list playlists around me",
      {:get, "/api/playlists?lat=51.504&lng=-0.127"},
      %{
        status: 200,
      }
    )

    # Get the nearest playlist
    assert_step(
      "I should be able to check the status of a playlist",
      {:get, "/api/playlists/#{playlist_id}"},
      %{
        status: 200,
        json: %{
          "name" => "Test Playlist",
          "id" => playlist_id,
          "tracks" => [],
          "playing" => %{}
        }
      }
    )

    # Search for tracks
    assert_step(
      "I should be able to search for tracks",
      {:get, "/api/search?q=Daft%20Punk"},
      []
    )

  end

  defp assert_step(message, {method, path}, resp), do: assert_step(message, {method, path, nil}, resp)
  defp assert_step(message, {method, path, body}, resp) do
    IO.puts message
    conn = conn(method, path, Poison.encode!(body)) |> put_req_header("content-type", "application/json")
    conn = PollDance.Api.call(conn, @opts)

    if expected_status = Map.get(resp, :status), do: assert conn.status == expected_status
    if expected_location = Map.get(resp, :location), do: assert hd(get_resp_header(conn, "location")) == expected_location
    if expected_json = Map.get(resp, :json), do: assert Poison.decode!(conn.resp_body) == expected_json
  end

end
