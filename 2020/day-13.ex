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

  def t1, do: solve([7,13,"x","x",59,"x",31,19])
  def t2, do: solve([1789,37,47,1889])

  def solve(buses) do
    buses = buses
            |> Enum.with_index()
            |> Enum.filter(fn {x, _} -> x != "x" end)

    [big | rest] = buses |> Enum.sort(fn {x, _}, {y, _} -> x >= y end)
    {fst, idx} = big
    
    div(100000000000000, fst)
    |> naturals()
    |> (filter_common(big, rest)).()
    |> Enum.take(1)
    |> IO.inspect()
    |> (fn [x] -> x * fst - idx end).()
   end

  def naturals(offset), do: Stream.unfold(offset, fn x -> {x, x + 1} end)

  def filter_common(x, t) do
    t
    |> Enum.map(increment(x)) 
    |> Enum.map(fn func ->
      fn stream -> 
        stream
        |> Stream.map(func)
        |> Stream.filter(&(&1))
      end
    end)
    |> pipe() 
  end

  def lcm(a, b), do: div((a * b), Integer.gcd(a, b))

  def pipe(f, g), do: fn x -> x |> f.() |> g.() end
  def pipe(fs), do: fs |> Enum.reverse() |> Enum.reduce(&pipe/2)

  def increment({x, dx}) do
    fn {y, dy} ->
      fn n -> 
        result = ((x * n) - dx + dy) / y
        if Float.floor(result) == result, do: n, else: false
      end
    end
  end

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

