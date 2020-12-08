defmodule Day5 do

  def part_1 do
    load()
    |> Enum.map(&find_seat_id/1)
    |> Enum.reduce(&max/2)
  end

  def part_2 do
    load()
    |> Enum.map(&find_seat_id/1)
    |> Enum.sort()
    |> Enum.reduce_while(
      nil,
      fn x, acc ->
        cond do
          acc == nil -> {:cont, x}
          x - 1 == acc -> {:cont, x}
          true -> {:halt, {acc, x}} 
        end
      end
    )
  end

  def find_seat_id(seat) do
    row = find_row(String.slice(seat, 0..6), 0, 127)
    col = find_col(String.slice(seat, 7..9), 0, 7)

    row * 8 + col
  end

  def find_row("F", low, high), do: low
  def find_row("B", low, high), do: high
  def find_row("F" <> rest, low, high) do
    find_row(rest, low, div(high - low, 2) + low)
  end
  def find_row("B" <> rest, low, high) do 
    find_row(rest, div(high - low, 2) + low + 1, high)
  end

  def find_col("L", low, high), do: low
  def find_col("R", low, high), do: high
  def find_col("L" <> rest, low, high) do 
    find_col(rest, low, div(high - low, 2) + low)
  end
  def find_col("R" <> rest, low, high) do 
    find_col(rest, div(high - low, 2) + low + 1, high)
  end

  def load do
    File.read!("day-5.input") 
    |> String.split("\n", trim: true)
  end


end
