defmodule Rule do
  defstruct [:bag, :contents]

  def parse_rule(line) do
    [bag | [contents]] = line
                         |> String.replace(["bag", "bags", "."], "")
                         |> String.split(" contain ", trim: true)
    
    %Rule{bag: String.trim(bag), contents: parse_contents(contents)}
  end

  def parse_contents(contents) do
    contents
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_count/1)
    |> Enum.filter(&(&1 != nil))
    |> Map.new()
  end

  def parse_count("no other"), do: nil
  def parse_count(line) do 
    {count, bag} = Integer.parse(line)
    {String.trim(bag), count}    
  end
end

defmodule Day7 do

  def part_1 do
    lookup = load()
             |> Enum.map(&Rule.parse_rule/1)
             |> build_lookup(%{})

    Map.keys(lookup)
    |> Enum.map(&(contains(&1, "shiny gold", lookup)))
    |> Enum.count(&(&1))
  end

  def part_2 do
    lookup = load()
             |> Enum.map(&Rule.parse_rule/1)
             |> build_lookup(%{})

    count_contents(lookup, "shiny gold")
  end

  def count_contents(lookup, bag) do
    case Map.get(lookup, bag, []) do
      [] -> 0
      contents ->
        contents
        |> Map.to_list()
        |> Enum.map(
          fn {bag, count} -> count * (1 + count_contents(lookup, bag)) end)
        |> Enum.sum()
    end

  end

  def contains(key, value, lookup) do
    case Map.get(lookup, key, []) do
      [] -> false
      contents -> 
        if Map.has_key?(contents, value) do
          true
        else
          Map.keys(contents)
          |> Enum.map(&(contains(&1, value, lookup)))
          |> Enum.any?()
        end
    end
  end

  def build_lookup([], lookup), do: lookup
  def build_lookup([head | tail], lookup) do
    build_lookup(
      tail,
      Map.put(lookup, head.bag, head.contents)
    )
  end

  def load do
    File.read!("day-7.input")
    |> String.split("\n", trim: true)
  end
end
