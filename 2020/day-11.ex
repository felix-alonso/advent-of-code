defmodule Day11 do

  defguard in_bounds(x, list) when 0 <= x and x < length(list)

  def part_1, do: solve(&by_adjacency/4)
  def part_2, do: solve(&by_visibility/4)

  def solve(method) do
    load()
    |> find_stable(method)
    |> count_occupied()
  end

  def count_occupied(seats) do
    seats
    |> Enum.map(fn row -> Enum.count(row, &(&1 == ?#)) end)
    |> Enum.sum()
  end

  def find_stable(seats, transform) do
    case next_gen(seats, transform) do
      next when next == seats -> next
      next -> find_stable(next, transform)
    end
  end

  def next_gen(seats, transform) do
    for {row, r_idx} <- Enum.with_index(seats) do
      for {seat, c_idx} <- Enum.with_index(row) do
        transform.(seats, seat, r_idx, c_idx)
      end
    end
  end

  def by_visibility(_, ?., _, _), do: ?.
  def by_visibility(seats, ?L, row, col) do
    if visible(seats, row, col) == 0, do: ?#, else: ?L
  end
  def by_visibility(seats, ?#, row, col) do
      if visible(seats, row, col) >= 5, do: ?L, else: ?#
  end

  def visible(seats, r_idx, c_idx) do
    directions()
    |> Enum.count(fn {x, y} -> next(seats, r_idx + x, c_idx + y, x, y) end)
  end

  def next(_, row, col, _, _) when row < 0 or col < 0, do: false
  def next(seats, row, col, drow, dcol) do
    case get_seat(seats, row, col) do
      ?. -> next(seats, row + drow, col + dcol, drow, dcol)
      x -> x == ?#
    end
  end

  def by_adjacency(_, ?., _, _), do: ?.
  def by_adjacency(seats, ?L, row, col) do
    if adjacent(seats, row, col) == 0, do: ?#, else: ?L
  end
  def by_adjacency(seats, ?#, row, col) do
      if adjacent(seats, row, col) >= 4, do: ?L, else: ?#
  end

  def adjacent(seats, row, col) do
    directions()
    |> Enum.count(fn {x, y} -> get_seat(seats, row + x, col + y) == ?#  end)
  end

  def directions do
    for x <- -1..1, y <- -1..1, not_origin(x, y), do: {x, y}
  end

  def not_origin(x, y), do: not(x == 0 and y == 0)

  def get_seat(seats=[fst|_], row, col)
    when in_bounds(row, seats) and in_bounds(col, fst),
    do: seats |> Enum.at(row) |> Enum.at(col) 
  def get_seat(_, _, _), do: nil

  def load do
    File.read!("day-11.input")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end
end

