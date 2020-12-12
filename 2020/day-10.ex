defmodule Day10 do
  
  def part_1 do
    ratings = load() |> Enum.sort()

    [0 | ratings]
    |> get_diffs(%{})
    |> (&(Map.get(&1, 1, 0) * Map.get(&1, 3, 0))).()
  end

  def part_2 do
    build_ratings()
    |> permutations()
  end

  def permutations([_]), do: 1
  def permutations(list=[h|t]) do
    case Process.get(list) do
      nil ->
        result = t
                 |> within_3(h)
                 |> Enum.map(&permutations/1)
                 |> Enum.sum()
        Process.put(list, result)
        result
      x -> x
    end
  end

  def within_3(list=[h|t], x) when h - x <= 3, do: [list|within_3(t, x)]
  def within_3(_, _), do: []

  def build_ratings do
    [0 | load()]
    |> Enum.sort()
  end

  def get_diffs([_], diffs) do
    Map.update(diffs, 3, 1, &(&1 + 1))
  end
  def get_diffs([fst, snd|tail], diffs) do
    get_diffs(
      [snd | tail],
      Map.update(diffs, snd - fst, 1, &(&1 + 1))
    )
  end

  def load do
    File.read!("day-10.input")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

IO.inspect(Day10.part_2)
