
defmodule Solve do

  def solve do
    load()
    |> Enum.filter(&is_valid/1)
    |> Enum.count()
  end 

  def solve_2 do
    load()
    |> Enum.filter(&is_valid_2/1)
    |> Enum.count()
  end 

  def is_valid(""), do: false
  def is_valid(line) do
    [{low, high}, c, pass] = parse_line(line)

    pass
    |> String.graphemes()
    |> Enum.count(&(c == &1))
    |> (fn x -> low <= x and x <= high end).()
  end

  def is_valid_2(""), do: false
  def is_valid_2(line) do
    [{low, high}, c, pass] = parse_line(line)

    pass
    |> String.graphemes()
    |> (fn x -> xor(Enum.at(x, low - 1) == c,  Enum.at(x, high - 1) == c) end).()
  end

  def xor(x, y) do
    case {x, y} do
      {true, false} -> true
      {false, true} -> true
      _ -> false
    end
  end

  def parse_line(line) do
    [r, c, pass] = line 
                    |> String.replace(":", "") 
                    |> String.split(" ")
    [parse_range(r), c, pass]
  end

  def parse_range(r) do
    [low, high] = String.split(r, "-")
    {String.to_integer(low), String.to_integer(high)}
  end

  def load do
    {:ok, data} = File.read("day-2-1.input")
    String.split(data, "\n")
  end
end

