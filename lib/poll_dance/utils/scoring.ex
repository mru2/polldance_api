defmodule PollDance.Utils.Scoring do

  # Decrease rate (higher = longer value)
  @decay 1130

  def score(timestamps, now \\ :os.timestamp) do
    timestamps
    |> Enum.map(
      fn ts ->
        ts
        |> get_delta_t(now)
        |> get_score()
      end
    )
    |> Enum.sum
  end

  defp get_delta_t({tm,ts,tu}, {nm,ns,nu}), do: (nm - tm) * 1_000_000 + (ns - ts) + (nu - tu) / 1_000_000

  defp get_score(delta_t) do
    :math.exp(-delta_t / @decay)
  end

end
