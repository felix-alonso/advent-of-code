defmodule Day17 do

  @input """
  ####...#
  ......##
  ####..##
  ##......
  ..##.##.
  #.##...#
  ....##.#
  .##.#.#.
  """

  @test ".#.\n..#\n###"

  def part_1, do: solve(@input, 3, 6)
  def part_2, do: solve(@input, 4, 6)
  def test_1, do: solve(@test, 3, 6)
  def test_2, do: solve(@test, 4, 6)

  def solve(input, dims, n) do
    input
    |> parse(List.duplicate(0, dims - 2))
    |> generations(n)
    |> Enum.count(fn {_, state} -> state == :alive end)
  end

  def generations(board, 0), do: board
  def generations(board, n) do
    next = Enum.reduce(board, board, 
      fn {coor, _}, acc -> 
        coor 
        |> neighbors() 
        |> Enum.reduce(acc, fn x, acc -> Map.update(acc, x, :dead, &(&1)) end)
      end)

    next
    |> sort_board()
    |> Enum.reduce(next, 
      fn {coor, state}, acc -> 
        next = coor  
               |> neighbors()
               |> Enum.count(&(is_alive?(board, &1)))
               |> change?(state)
        Map.put(acc, coor, next)
    end)
    |> generations(n - 1)
  end

  def is_alive?(board, coor), do: Map.get(board, coor, :dead) == :alive

  def change?(x, :alive) when x < 2 or 3 < x, do: :dead
  def change?(x, :dead) when x == 3, do: :alive
  def change?(_, state), do: state

  def parse(text, dims) do
    String.graphemes(text)
    |> Enum.reduce({0, 0, %{}}, fn 
      "\n", {r, _, board} -> {r + 1, 0, board}
      ".", {r, c, board} -> {r, c + 1, Map.put(board, dims ++ [r, c], :dead)}
      "#", {r, c, board} -> {r, c + 1, Map.put(board, dims ++ [r, c], :alive)}
    end) 
    |> elem(2)
  end

  def neighbors(coor), do: coor |> _neighbors() |> List.delete(coor)
  def _neighbors([t]), do: [[t-1], [t], [t+1]]
  def _neighbors([h|t]), do:
    t |> _neighbors() |> Enum.flat_map(&([[h-1|&1], [h|&1], [h+1|&1]]))

  def sort_pair([h1], [h2]), do: h1 <= h2
  def sort_pair([h1|t1], [h2|t2]) when h1 == h2, do: sort_pair(t1, t2)
  def sort_pair([h1|t1], [h2|t2]), do: sort_pair(t1, t2)
  def sort_pair({[h1|t1], _}, {[h2|t2], _}) when h1 == h2, do: sort_pair(t1, t2)
  def sort_pair({[h1|_], _}, {[h2|_], _}), do: h1 <= h2

  def sort_board(board), do: board |> Enum.map(&(&1)) |> Enum.sort(&sort_pair/2)
end
