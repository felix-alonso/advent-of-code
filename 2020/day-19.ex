defmodule Day19 do

  def part_1 do
    {rules, msgs} = load()

    msgs |> Enum.count(&(valid?(&1, rules)))
  end

  def part_2 do
    {rules, msgs} = load_modified()

    msgs |> Enum.count(&(valid?(&1, rules)))
  end

  def valid?(msg, rules), do: match(msg, Map.get(rules, "0"), rules)

  def match([], [], _), do: true
  def match([], _, _), do: false
  def match(_, [], _), do: false

  def match([char|text], [{:char, char}|rest], rules), do: match(text, rest, rules)
  def match(_, [{:char, _char}|_], _rules), do: false

  def match(str, [[l, r] | rest], rules) when is_list(l) and is_list(r) do
    [l, r] |> Enum.any?(fn branch -> match(str, [branch | rest], rules) end)
  end
  
  def match(str, [next|rest], rules) when is_list(next) do
    match(str, Enum.concat(next, rest), rules)
  end

  def match(str, [next | rest], rules) when is_binary(next) do
    rule = Map.get(rules, next)
    match(str, [rule | rest], rules)
  end

  def parse([rules, msgs]), do: {parse_rules(rules), parse_messages(msgs)}

  def parse_messages(lines) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end
  def parse_rules(lines) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_rule/1)
    |> Enum.into(%{})
  end

  def parse_rule(line) do
    with [idx, rule] <- String.split(line, ": ", trim: true),
         ors <- String.split(rule, " | ", trim: true),
         ands <- Enum.map(ors, &parse_clause/1)
    do
      {idx, ands}
    end
  end

  def parse_clause("\"a\""), do: {:char, "a"}
  def parse_clause("\"b\""), do: {:char, "b"}
  def parse_clause(text), do: String.split(text, " ", trim: true)

  def load_modified(name \\ "day-19.input") do
    {rules, msgs} = load(name)

    rules = rules
            |> Map.put("8", [["42"], ["42", "8"]])
            |> Map.put("11", [["42", "31"], ["42", "11", "31"]])
    {rules, msgs}
  end

  def load(name \\ "day-19.input") do
    name
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> parse()
  end
end

