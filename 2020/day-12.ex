defmodule Day12 do

  def rotations, do: ["N", "E", "S", "W"]

  def rotate(relative, dir, places) do
    cur = Enum.find_index(rotations(), &(relative == &1))
    places = div(places, 90)
    case dir do
      "R" -> Enum.at(rotations(), rem(cur + places, 4))
      "L"  -> Enum.at(rotations(), rem(cur - places, 4))
    end
  end

  def parse(<<dir :: binary-size(1)>> <> dist), do: {dir, String.to_integer(dist)}
  
  def load do
    File.read!("day-12.input")
    |> String.split("\n", trim: true)
    |> Enum.map(&parse/1)
  end
end

defmodule Day12.Ship do
  defstruct [dir: "E", x: 0, y: 0]
end

defmodule Day12.Waypoint do
  alias Day12.Waypoint

  defstruct [x: 10, y: 1]

  def move(w=%{y: y}, "N", dist), do: %{w | y: y + dist}
  def move(w=%{y: y}, "S", dist), do: %{w | y: y - dist}
  def move(w=%{x: x}, "E", dist), do: %{w | x: x + dist}
  def move(w=%{x: x}, "W", dist), do: %{w | x: x - dist}

  def rotate(w=%{x: x, y: y}, "R", rotations) do
    case rotations |> div(90) |> rem(4) do
      0 -> w
      1 -> %{w | x: y, y: -x}
      2 -> %{w | x: -x, y: -y}
      3 -> %{w | x: -y, y: x}
    end
  end

  def rotate(w=%{x: x, y: y}, "L", rotations) do
    case rotations |> div(90) |> rem(4) do
      0 -> w
      1 -> %{w | x: -y, y: x}
      2 -> %{w | x: -x, y: -y}
      3 -> %{w | x: y, y: -x}
    end
  end
end

defmodule Day12.Part1 do
  import Day12
  alias Day12.Ship

  def solve do
    load()
    |> Enum.reduce(%Ship{}, &move/2)
    |> (fn %{x: x, y: y} -> abs(x) + abs(y) end).()
  end

  def move({"F", dist}, state=%{dir: dir}), do: move({dir, dist}, state)    

  def move({"N", dist}, state=%{y: y}), do: %{state | y: y + dist}    
  def move({"S", dist}, state=%{y: y}), do: %{state | y: y - dist}    
  def move({"E", dist}, state=%{x: x}), do: %{state | x: x + dist}    
  def move({"W", dist}, state=%{x: x}), do: %{state | x: x - dist}    

  def move({dir, dist}, s=%{dir: relative}), do: %{s | dir: rotate(relative, dir, dist)}
end

defmodule Day12.Part2 do
  import Day12
  alias Day12.Ship
  alias Day12.Waypoint

  def part_2 do
    load()
    |> Enum.reduce({%Ship{}, %Waypoint{}}, &move/2)
    |> (fn {%{x: x, y: y}, _} -> abs(x) + abs(y) end).()
  end

  def move({"N", dist}, {s, w}), do: {s, Waypoint.move(w, "N", dist)}
  def move({"S", dist}, {s, w}), do: {s, Waypoint.move(w, "S", dist)}
  def move({"E", dist}, {s, w}), do: {s, Waypoint.move(w, "E", dist)}
  def move({"W", dist}, {s, w}), do: {s, Waypoint.move(w, "W", dist)}

  def move({"F",  dist}, {s=%{x: sx, y: sy}, w=%{x: wx, y: wy}}) do 
    {%{s | x: sx + dist * wx, y: sy + dist * wy}, w}
  end

  def move({dir, rotations}, {s, w}), do: {s, Waypoint.rotate(w, dir, rotations)}
end
