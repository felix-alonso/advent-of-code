defmodule Day9 do

  def part_1 do
    {preamble, stream} = load() |> Enum.split(25)

    Enum.reduce_while(stream, preamble, &find_nonsum/2)
  end

  def part_2 do
    target = part_1()

    load()
    |> find_weakness(target)
    |> sum_min_and_max()
  end

  def sum_min_and_max(list) do
    Enum.min(list) + Enum.max(list)
  end

  def find_weakness([h|t], target) do
    pair = Enum.reduce_while(t, {h, [h]},
      fn x, {acc, list} ->
        if x + acc >= target do
          {:halt, {x + acc, [x | list]}}
        else
          {:cont, {x + acc, [x | list]}}
        end
      end)

    case pair do
      {^target, list} -> list
      _ -> find_weakness(t, target)
    end
  end

  def find_nonsum(x, acc=[_|t]) do
    if pair_sum_to?(x, acc) do
      {:cont, List.insert_at(t, -1, x)} # boo, O(N) insertion!
    else
      {:halt, x}
    end
  end

  def pair_sum_to?(_, []), do: false
  def pair_sum_to?(x, [head | tail]) do
    if Enum.any?(tail, &(head + &1 == x)) do
      true
    else
      pair_sum_to?(x, tail)
    end
  end

  def load do
    File.read!("day-9.input")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
