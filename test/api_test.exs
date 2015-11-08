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
      %{
        status: 200,
        json: [
          %{"artist" => "Daft Punk", "id" => "dz:67238732", "title" => "Instant Crush"}, %{"artist" => "Daft Punk", "id" => "dz:66609426", "title" => "Get Lucky (Radio Edit)"}, %{"artist" => "Daft Punk", "id" => "dz:67238735", "title" => "Get Lucky"}, %{"artist" => "Daft Punk", "id" => "dz:3135553", "title" => "One More Time"}, %{"artist" => "Daft Punk", "id" => "dz:67238733", "title" => "Lose Yourself to Dance"}, %{"artist" => "Pentatonix", "id" => "dz:78383429", "title" => "Daft Punk"}, %{"artist" => "Daft Punk", "id" => "dz:67238728", "title" => "Give Life Back to Music"}, %{"artist" => "Daft Punk", "id" => "dz:3138820", "title" => "Around The World"}, %{"artist" => "Daft Punk", "id" => "dz:67238730", "title" => "Giorgio by Moroder"}, %{"artist" => "Daft Punk", "id" => "dz:67238739", "title" => "Doin' it Right"}, %{"artist" => "Daft Punk", "id" => "dz:3138878", "title" => "Harder Better Faster Stronger"}, %{"artist" => "Daft Punk", "id" => "dz:67238731", "title" => "Within"}, %{"artist" => "Daft Punk", "id" => "dz:67238729", "title" => "The Game of Love"}, %{"artist" => "Daft Punk", "id" => "dz:3135554", "title" => "Aerodynamic"}, %{"artist" => "Daft Punk", "id" => "dz:3135556", "title" => "Harder Better Faster Stronger"}, %{"artist" => "Daft Punk", "id" => "dz:67238734", "title" => "Touch"}, %{"artist" => "Daft Punk", "id" => "dz:3129772", "title" => "Da Funk"}, %{"artist" => "Daft Punk", "id" => "dz:67238740", "title" => "Contact"}, %{"artist" => "Daft Punk", "id" => "dz:67238736", "title" => "Beyond"}, %{"artist" => "Daft Punk", "id" => "dz:3135555", "title" => "Digital Love"}, %{"artist" => "Daft Punk", "id" => "dz:3135561", "title" => "Something About Us"}, %{"artist" => "Daft Punk", "id" => "dz:3167843", "title" => "Around The World / Harder Better Faster Stronger"}, %{"artist" => "Daft Punk", "id" => "dz:3135563", "title" => "Veridis Quo"}, %{"artist" => "Daft Punk", "id" => "dz:67238738", "title" => "Fragments of Time"}, %{"artist" => "Daft Punk", "id" => "dz:67238737", "title" => "Motherboard"}
        ]
      }
    )

    # Adding a track
    assert_step(
      "I should be able to add a track",
      {:post, "/api/playlists/#{playlist_id}/tracks", %{"artist" => "Daft Punk", "id" => "dz:67238732", "title" => "Instant Crush"}},
      %{
        status: 200,
        json: %{
          "name" => "Test Playlist",
          "id" => playlist_id,
          "tracks" => [
            %{
              "title" => "Instant Crush",
              "artist" => "Daft Punk",
              "id" => "dz:67238732"
            }
          ],
          "playing" => %{}
        }
      }
    )

    # Vote for a track
    assert_step(
      "I should be able to vote for a track",
      {:post, "/api/playlists/#{playlist_id}/tracks/dz:67238732"},
      %{
        status: 200,
        json: %{
          "name" => "Test Playlist",
          "id" => playlist_id,
          "tracks" => [
            %{
              "title" => "Instant Crush",
              "artist" => "Daft Punk",
              "id" => "dz:67238732"
            }
          ],
          "playing" => %{}
        }
      }
    )

    # Pop the top track
    assert_step(
      "I should be able to pop the top track",
      {:delete, "/api/playlists/#{playlist_id}/tracks"},
      %{
        status: 200,
        json: %{
          "title" => "Instant Crush",
          "artist" => "Daft Punk",
          "id" => "dz:67238732"
        }
      }
    )

    # Should have updated the playlist
    assert_step(
      "It should have updated the playlist",
      {:get, "/api/playlists/#{playlist_id}"},
      %{
        status: 200,
        json: %{
          "name" => "Test Playlist",
          "id" => playlist_id,
          "tracks" => [],
          "playing" => %{
            "title" => "Instant Crush",
            "artist" => "Daft Punk"
          }
        }
      }
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
