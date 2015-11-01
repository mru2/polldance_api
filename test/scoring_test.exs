defmodule ScoringTest do
  use ExUnit.Case

  alias PollDance.Utils.Scoring

  # Utils for votes
  def now do
    {1446, 406573, 875816}
  end

  def minutes_ago(mins) do
    {1446, 406573 - 60 * mins, 875816}
  end

  # Util for testing
  def assert_order(vote_collections) do
    scores = vote_collections |> Enum.map( fn col -> Scoring.score(col, now) end )
    assert scores == ( scores |> Enum.sort |> Enum.reverse )
  end

  test "newer votes are better scored" do
    assert_order( [
      [ now ],
      [ minutes_ago(3) ]
    ] )
  end

  test "2 votes 10 minutes ago are better than one right now" do
    assert_order( [
      [ minutes_ago(10), minutes_ago(10) ],
      [ now ]
    ] )
  end

  test "2 votes now are better than 3 10 minutes ago" do
    assert_order( [
      [ now, now ],
      [ minutes_ago(10), minutes_ago(10), minutes_ago(10) ]
    ] )
  end

  test "2 votes now and 5 minutes ago are worse than 3 ten minutes ago" do
    assert_order( [
      [ now, minutes_ago(5) ],
      [ minutes_ago(10), minutes_ago(10), minutes_ago(10) ]
    ] )
  end

  test "And this is independant of the time voted" do
    assert_order( [
      [ minutes_ago(10), minutes_ago(10) ],
      [ minutes_ago(20), minutes_ago(20), minutes_ago(20) ]
    ] )
  end

  test "1 vote now is better than 3 half an hour ago" do
    assert_order( [
      [ now ],
      [ minutes_ago(30), minutes_ago(30), minutes_ago(30) ]
    ] )
  end

  test "1 vote now is worse than 3 15 minutes ago" do
    assert_order( [
      [ minutes_ago(15), minutes_ago(15), minutes_ago(15) ],
      [ now ]
    ] )
  end

  test "in a battle, consistency trumps all" do
    assert_order( [
      [ minutes_ago(2), minutes_ago(2), minutes_ago(2) ],
      [ now, minutes_ago(5), minutes_ago(5) ]
    ] )
  end

  test "1 vote now is not better than 5 30 minutes ago" do
    assert_order( [
      [ minutes_ago(30), minutes_ago(30), minutes_ago(30), minutes_ago(30), minutes_ago(30) ],
      [ now ]
    ] )
  end

end
