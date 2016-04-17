defmodule PollDanceApi.Router do
  use PollDanceApi.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PollDanceApi do
    pipe_through :api
  end
end
