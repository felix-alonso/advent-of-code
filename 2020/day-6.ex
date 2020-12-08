defmodule Day6 do

  def part_1 do
    load()
    |> Enum.map(&to_set/1)
    |> Enum.map(&MapSet.size/1)
    |> Enum.sum()
  end

  def part_2 do
    load()
    |> Enum.map(&to_sets/1)
    |> Enum.map(&intersect/1)
    |> Enum.map(&MapSet.size/1)
    |> Enum.sum()
  end

  def intersect(groups) do
    if length(groups) == 1 do
      Enum.at(groups, 0)
    else
      Enum.reduce(groups, &MapSet.intersection/2)
    end
  end


  def to_set(group) do
    group
    |> String.replace("\n", "")
    |> String.graphemes()
    |> MapSet.new()
  end

  def to_sets(group) do
    group
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&MapSet.new/1)
  end

  def load do
    File.read!("day-6.input")
    |> String.split("\n\n", trim: true)
  end

end
