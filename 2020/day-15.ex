defmodule Day15 do

  @input [15,5,1,4,7,0]

  def part_1 do
    @input
    |> start(%{}, 1)
    |> play(2020)
    |> IO.inspect()
  end

  def part_2 do
    @input
    |> start(%{}, 1)
    |> play(30000000)
    |> IO.inspect()
  end

  def play({_, turn, last}, max) when turn > max, do: last
  def play({seen, turn, last}, max) do
    number = get_last(seen, last)
    seen = update_last_seen(seen, number, turn)
    play({seen, turn + 1, number}, max)
  end

  def start([], seen, turn), do: {seen, turn, 0}
  def start([h|t], seen, turn) do
    start(t, update_last_seen(seen, h, turn), turn + 1) 
  end

  def get_last(seen, key) do
    case Map.get(seen, key) do
      {f, s} -> f - s
      _ -> 0
    end
  end

  def update_last_seen(seen, key, turn) do
    Map.update(seen, key, turn, fn
      {f,_} -> {turn,f}
      x -> {turn, x}
    end)
  end
end

