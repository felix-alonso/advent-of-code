defmodule Day16 do

  def part_1 do
    {rules, _mine, others} = load()

    others
    |> Enum.flat_map(&(find_invalids(&1, rules)))
    |> Enum.sum()
  end

  def part_2 do
    {rules, [mine], others} = load()

    order = others
            |> Enum.filter(&(valid_ticket?(&1, rules)))
            |> find_field_order(rules)

    mult_departure(mine, order, 0)
  end

  def mult_departure(ticket, _, pos) when length(ticket) <= pos, do: 1
  def mult_departure(ticket, order, pos) do
    if Map.get(order, pos) |> String.starts_with?("departure") do
      Enum.at(ticket, pos) * mult_departure(ticket, order, pos + 1)
    else
      mult_departure(ticket, order, pos + 1)
    end
  end

  def find_field_order(tickets, rules) do
    rules
    |> Enum.map(&(possible_fields(&1, tickets)))
    |> Enum.sort(fn {_, o1}, {_, o2} -> length(o1) <= length(o2) end)
    |> Enum.reduce(%{}, &find_order/2)
  end

  def find_order({name, [h|t]}, placed) do
    if Map.has_key?(placed, h) do
      find_order({name, t}, placed)
    else
      Map.put(placed, h, name)
    end
  end

  def possible_fields(rule=[name,_,_], tickets=[h|_]) do
    base = List.duplicate(true, length(h))
      
    options = Enum.reduce(tickets, base, fn
                t, acc -> 
                  t |> test_columns(rule) |> land(acc)
              end)
              |> Enum.with_index()
              |> Enum.filter(fn {valid?, _} -> valid? end)
              |> Enum.map(fn {_, idx} -> idx end)

    {name, options}
  end

  def land([], []), do: []
  def land([h1|t1], [h2|t2]), do: [h1 and h2|land(t1, t2)]

  def test_columns([], _), do: []
  def test_columns([h|t], rule), do: [valid?(h, rule)|test_columns(t, rule)]

  def test_1 do
    input = """
    class: 1-3 or 5-7
    row: 6-11 or 33-44
    seat: 13-40 or 45-50

    your ticket:
    7,1,14

    nearby tickets:
    7,3,47
    40,4,50
    55,2,20
    38,6,12
    """
    {rules, _mine, others} = parse(input)

    others
    |> Enum.flat_map(&(find_invalids(&1, rules)))
    |> Enum.sum()
  end

  def valid_ticket?(t, rules) do
    case find_invalids(t, rules) do
      [] -> true
      _  -> false
    end
  end

  def find_invalids([], _), do: []
  def find_invalids([h|t], rules) do
    rest = find_invalids(t, rules)
    if matches_rule?(h, rules) do
      rest
    else 
      [h|rest]
    end
  end

  def matches_rule?(h, rules), do:  Enum.any?(rules, &(valid?(h, &1)))

  def valid?(x, [_, r1, r2]), do: in_range(x, r1) or in_range(x, r2)

  def in_range(x, [low, high]), do: low <= x and x <= high

  def parse(lines) do
    with [rules, mine, others] <- String.split(lines, "\n\n", trim: true),
         rules <- parse_rules(rules),
         mine <- parse_tickets(mine),
         others <- parse_tickets(others) do
      {rules, mine, others}
    end
  end

  def parse_tickets(lines) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(fn l -> map_delimited(l, ",", &String.to_integer/1) end)
  end

  def parse_rules(lines), do: map_delimited(lines, "\n", &parse_rule/1)

  def parse_rule(line) do
    with [name, r1, r2] <- String.split(line, [": ", " or "]),
         r1 <- parse_range(r1),
         r2 <- parse_range(r2) do
      [name, r1, r2]
    end
  end

  def parse_range(range), do: map_delimited(range, "-", &String.to_integer/1)

  def map_delimited(text, delimiter, func) do
    text |> String.split(delimiter) |> Enum.map(func)
  end

  def load, do: File.read!("day-16.input") |> parse() 
end
