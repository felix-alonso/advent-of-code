defmodule Day21 do
  
  def part_1 do
    food = load()
    allergens = food |> Enum.map(&(elem(&1, 1))) |> Enum.reduce(&MapSet.union/2)

    mapping = allergens
              |> Enum.map(&(find_options(&1, food)))
              |> find_words(%{})
    
    words = Map.values(mapping)
    food 
    |> Enum.flat_map(fn {words, _} -> words end)
    |> Enum.count(&(&1 not in words))
  end

  def part_2 do
    food = load()
    allergens = food |> Enum.map(&(elem(&1, 1))) |> Enum.reduce(&MapSet.union/2)

    allergens
    |> Enum.map(&(find_options(&1, food)))
    |> find_words(%{})
    |> Enum.sort(fn {a1, _}, {a2, _} -> a1 < a2 end)
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.join(",")
    
  end

  def find_words([], mapping), do: mapping
  def find_words(options=[{allergen, opts}|rest], mapping) do
    if Enum.count(opts) > 1 do
      options |> Enum.sort(&sorter/2) |> find_words(mapping)
    else
      [word] = Enum.take(opts, 1)
      rest = Enum.map(rest, fn {a, opts} -> {a, MapSet.delete(opts, word)} end)
      mapping = Map.put(mapping, allergen, word)
      find_words(rest, mapping)
    end    
  end
 
  def sorter({_, o1}, {_, o2}), do: Enum.count(o1) < Enum.count(o2)


  def find_options(allergen, food) do
    words = food |> Enum.map(&(elem(&1, 0))) |> Enum.reduce(&MapSet.union/2)

    
    options = Enum.reduce(food, words, fn 
                {words, allergens}, options -> 
                  if MapSet.member?(allergens, allergen) do
                    MapSet.intersection(words, options)
                  else
                    options
                  end
              end)
    {allergen, options}
  end

  def load, do: File.read!("day-21.input") |> parse()

  def parse(lines) do
    lines
    |> String.split("\n")
    |> Enum.map(&parse_ingredients/1)
  end

  def parse_ingredients(line) do
    {unknown, allergens} = line 
                           |> String.replace([",", "(", ")"], "")
                           |> String.split(" ", trim: true)
                           |> Enum.split_while(&(&1 != "contains"))

    allergens = allergens |> List.delete("contains") |> MapSet.new() 

    {MapSet.new(unknown), allergens}
  end
end
