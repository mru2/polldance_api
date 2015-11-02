# Guarantees the presence of a user id in the cookies
defmodule PollDance.Plugs.UserId do
  alias Plug.Conn
  @behaviour Plug

  @cookie_name "_polldance_user_id"
  @private_name :user_id

  def init(_opts \\ []) do
    :ok
  end

  def call(conn, config) do
    conn
    |> Conn.fetch_cookies
    |> handle
  end

  # Fetch a cookie value
  def get(%Conn{private: %{@private_name => user_id}}), do: user_id

  # Handle request : cookie present
  defp handle(%Conn{cookies: %{@cookie_name => user_id}} = conn) do
    conn
    |> Conn.put_private(@private_name, user_id)
  end

  # Handle request : cookie not present
  defp handle(conn) do
    user_id = generate
    conn
    |> Conn.put_private(@private_name, user_id)
    |> Conn.put_resp_cookie(@cookie_name, user_id)
  end

  # Generate a new user id
  defp generate do
    UUID.uuid1()
  end
end
