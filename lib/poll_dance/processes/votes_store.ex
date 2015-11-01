defmodule PollDance.Processes.VotesStore do
  use ExActor.GenServer

  defstart start_link, gen_server_opts: :runtime, do: initial_state([])

end
