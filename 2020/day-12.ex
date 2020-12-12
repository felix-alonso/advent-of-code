defmodule Day12 do

  def directions do 
    %{
      "F" => :forward,
      "L" => :left,
      "R" => :right,
      "N" => :north,
      "E" => :east,
      "S" => :south,
      "W" => :west,
    }
  end

  def rotations, do: [:north, :east, :south, :west]

  def rotate(relative, dir, places) do
    cur = Enum.find_index(rotations(), &(relative == &1))
    places = div(places, 90)
    case dir do
      :right -> Enum.at(rotations(), rem(cur + places, 4))
      :left  -> Enum.at(rotations(), rem(cur - places, 4))
    end
  end

  def parse_direction(<<dir :: binary-size(1)>> <> dist) do
    {Map.get(directions(), dir), String.to_integer(dist)}
  end
  
  def load do
    File.read!("day-12.input")
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_direction/1)
  end
end

defmodule Day12.Ship do
  defstruct [dir: :east, x: 0, y: 0]
end

defmodule Day12.Waypoint do
  alias Day12.Waypoint

  defstruct [x: 10, y: 1]

  def move(w=%{y: y}, :north, dist), do: %{w | y: y + dist}
  def move(w=%{y: y}, :south, dist), do: %{w | y: y - dist}
  def move(w=%{x: x}, :east,  dist), do: %{w | x: x + dist}
  def move(w=%{x: x}, :west,  dist), do: %{w | x: x - dist}

  def rotate(w=%{x: x, y: y}, relative, :right, rotations) do
    case rotations |> div(90) |> rem(4) do
      0 -> w
      1 -> %{w | x: y, y: -x}
      2 -> %{w | x: -x, y: -y}
      3 -> %{w | x: -y, y: x}
    end
  end

  def rotate(w=%{x: x, y: y}, relative, :left, rotations) do
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

  def move({:forward, dist}, state=%{dir: dir}), do: move({dir, dist}, state)    

  def move({:north, dist}, state=%{y: y}), do: %{state | y: y + dist}    
  def move({:south, dist}, state=%{y: y}), do: %{state | y: y - dist}    
  def move({:east, dist}, state=%{x: x}),  do: %{state | x: x + dist}    
  def move({:west, dist}, state=%{x: x}),  do: %{state | x: x - dist}    

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

  def move({:north, dist}, {s, w}), do: {s, Waypoint.move(w, :north, dist)}
  def move({:south, dist}, {s, w}), do: {s, Waypoint.move(w, :south, dist)}
  def move({:east,  dist}, {s, w}), do: {s, Waypoint.move(w, :east, dist)}
  def move({:west,  dist}, {s, w}), do: {s, Waypoint.move(w, :west, dist)}

  def move({:forward,  dist}, {s=%{x: sx, y: sy}, w=%{x: wx, y: wy}}) do 
    {%{s | x: sx + dist * wx, y: sy + dist * wy}, w}
  end

  def move({dir, rotations}, {s=%{dir: relative}, w}) do 
    {s, Waypoint.rotate(w, relative, dir, rotations)}
  end
end
