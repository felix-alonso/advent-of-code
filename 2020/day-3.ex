defmodule Day3 do

  def solve do
    course = File.read!("day-3.input")
             |> String.trim()
             |> String.split("\n")

    [{1,1},{1,3},{1,5},{1,7},{2,1}]
    |> Enum.map(&(path(&1, course)))
    |> Enum.reduce(1, fn {_, trees}, product -> product * trees end)
  end

  def path({rise, run}, course) do
    course
    |> Enum.take_every(rise)
    |> Enum.reduce(
        {0, 0},
        fn line, {col, trees} ->
          next = case {run + col, String.length(line)} do
            {x, len} when x >= len -> x - len
            {x, _} -> x 
          end
          case String.at(line, col) do
            "." -> {next, trees}
            "#" -> {next, trees + 1}
          end
        end
      )
  end

end


defmodule Solve do
  defstruct [:pos, :trees, :slope]


  def solve do
    load()
    |> Enum.reduce({0, 0}, &check/2)
  end

  def check("", {_, trees}), do: trees
  def check(row, {column, trees}) do
    pos = next(column, String.length(row))
    case String.at(row, column) do
      "." -> {pos, trees}
      "#" -> {pos, trees + 1}
    end
  end

  def next(column, width) do
    case column + 3 do
      x when x < width -> x
      x -> x - width 
    end
  end

  def solve_2 do
    course = load()
    extent = {String.length(Enum.at(course, 0)), Enum.count(course)}
    [
      %Solve{pos: {0, 0}, trees: 0, slope: {1, 1}}, 
      %Solve{pos: {0, 0}, trees: 0, slope: {3, 1}}, 
      %Solve{pos: {0, 0}, trees: 0, slope: {5, 1}}, 
      %Solve{pos: {0, 0}, trees: 0, slope: {7, 1}}, 
      %Solve{pos: {0, 0}, trees: 0, slope: {1, 2}}, 
    ]
    |> Enum.map(&(check_2(course, &1, extent)))
    |> Enum.reduce(1, &*/2)
  end

  def check_2(_, %Solve{pos: nil, trees: trees}, _), do: trees
  def check_2(course, s=%Solve{pos: cur, slope: slope}, extent) do
    pos = next_2(cur, extent, slope)
    string = Enum.at(course, elem(cur, 1))
    if string == "" do
      check_2(course, %Solve{s | pos: nil}, extent)
    else
      trees = case String.at(string, elem(cur, 0)) do
        "." -> s.trees
        "#" -> s.trees + 1
        x -> IO.puts("#{string}.#{elem(cur, 0)}: '#{x}'")
          raise "what?"
      end

      check_2(course, %Solve{s | pos: pos, trees: trees}, extent)
    end
  end

  def next_2({x, y}, {max_x, max_y}, {run, rise}) do
    case {x + run, y + rise} do
      {_a, b} when b >= max_y -> nil
      {a, b} when a >= max_x -> {a - max_x, b}
      {a, b} -> {a, b}
    end
  end

  def check_2("", {_, trees}), do: trees
  def check_2(row, {column, trees}) do
    pos = next(column, String.length(row))
    case String.at(row, column) do
      "." -> {pos, trees}
      "#" -> {pos, trees + 1}
    end
  end

  def load do
    {:ok, data} = File.read("day-3.input")
    String.split(data, "\n")
  end

end
