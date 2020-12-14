defmodule Day13 do

  def part_1 do
    with [time, buses] <- load() do
      buses
      |> Enum.filter(&(&1 != "x"))
      |> Enum.map(&(nearest(&1, time)))
      |> Enum.min_by(fn {_, t} -> t end)
      |> (fn {n, t} -> n * (t - time) end).()
    end
  end

  def part_2 do
    with [_, buses] <- load() do
      solve(buses)
    end
  end

  def t1, do: IO.inspect(solve([7,13,"x","x",59,"x",31,19])) == 1068781
  def t2, do: IO.inspect(solve([1789,37,47,1889])) == 1202161486

  def solve(buses) do
    buses
    |> Enum.with_index()
    |> Enum.filter(fn {x, _} -> x != "x" end)
    |> Enum.reduce({0, 1}, &next/2)
    |> elem(0)
  end

  @doc """
  This is a blatant steal from voltane:

  https://elixirforum.com/t/advent-of-code-2020-day-13/36180/5

  However, I would like to keep attempting the rest of the puzzles
  and I am a bit burnt on this puzzle so here we are.

  That said, my previous version worked for the test cases and should
  have completed the actual problem (eventually)...
  """
  def next({bus, index}, {time, step}) do
    if rem(time + index, bus) == 0 do
      {time, lcm(step, bus)}
    else
      next({bus, index}, {time + step, step})
    end
  end

  def lcm(a, b), do: div((a * b), Integer.gcd(a, b))

  def nearest(x, goal) do
    case {div(goal, x), rem(goal, x)} do
      {_, 0} -> {x, goal}
      {y, _} -> {x, (y + 1) * x}
    end
  end

  def load do
    File.read!('day-13.input')
    |> String.split("\n", trim: true)
    |> parse()
  end

  def parse([time, buses]), do: [String.to_integer(time), parse_buses(buses)]

  def parse_buses(buses) do
    buses
    |> String.split(",")
    |> Enum.map(&parse_bus/1)
  end

  def parse_bus("x"), do: "x"
  def parse_bus(bus), do: String.to_integer(bus)
end

