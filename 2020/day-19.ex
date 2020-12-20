defmodule Day19 do

  def part_1 do
    {rules, msgs} = load()

    msgs |> Enum.count(&(valid?(&1, rules)))
  end

  def part_2 do
    {rules, msgs} = load_modified()

    print(rules)
    nil
    #msgs |> Enum.count(&(valid?(&1, rules)))
  end

  def test_1 do
    {rules, msgs} = load("day-19-test-1.input")
    msgs |> Enum.filter(&(valid?(&1, rules)))
  end

  def test_2 do
    {rules, msgs} = load_modified("day-19-test-2.input") |> print()
    
    ["aaaaabbaabaaaaababaa"]
    #msgs 
    |> Enum.filter(&(valid?(&1, rules)))
  end

  def test_3 do
    rules = %{1 => "a", 2 => "b", 3 => [[1, 2], [1, 3, 2]], 4 => [[1, 4], [1]]} 
    match("aaabbb", 3, rules) |> print()
    match("aaabbb", 4, rules) |> print()
  end 

  def valid?(msg, rules=%{}) do
    case match(msg, Map.get(rules, 0), rules) do
      {:ok, ""} -> true
      x -> 
        print(x)
        false
    end
  end


  def build(func, rules) when is_function(func), do: rules
  def build(idx, func, rules) when is_function(func), do: rules

  def build(idx, char, rules) when is_bitstring(char), do: Map.put(rules, idx, consume(char))
  def build(term, rules) when is_integer(term), do: build(term, Map.get(rules, term), rules)

  def build(terms=[h|_], rules) when is_integer(h), 
    do: Enum.reduce(terms, rules, fn x, acc -> build(x, acc) end)

  def build(idx, terms=[h|_], rules) when is_integer(h) do
    rules = Enum.reduce(terms, rules, fn x, acc -> build(x, acc) end)

    rule = terms |> Enum.map(&(Map.get(rules, &1))) |> each()

    Map.put(rules, idx, rule)
  end

  def build(idx, terms=[l,r], rules) when is_list(l) and is_list(r) do
    rules = Enum.reduce(terms, rules, fn x, acc -> build(x, acc) end)

    l = Enum.map(l, &(Map.get(rules, &1)))
    r = Enum.map(r, &(Map.get(rules, &1)))

    Map.put(rules, idx, either(each(l), each(r)))
  end

  def consume(char) do
    fn 
      <<n::bytes-size(1)>> <> rest when n == char -> {:ok, rest}
      str -> {:error, str}
    end
  end

  def either(p1, p2) do
    fn msg ->
      case p1.(msg) do
        {:error, _} -> p2.(msg)
        success -> success
      end
    end
  end

  def both(p1, p2) do
    fn msg ->
      with {:ok, rest} <- p1.(msg) do
        p2.(rest)
      end
    end
  end

  def each(parsers) do
    fn msg ->
      Enum.reduce(parsers, {:ok, msg}, fn
        p1, {:ok, rest} -> p1.(rest)
        _, {:error, x} -> {:error, x}
          end
      )
    end
  end

  def match(msg, tokens=[h|_], rules) when is_list(h), do: por(msg, tokens, rules)
  def match(msg, tokens=[h|_], rules) when not is_list(h), do: pand(msg, tokens, rules)

  def match(msg, rule, rules) when is_integer(rule), do: match(msg, Map.get(rules, rule), rules)
  def match(<<token::bytes-size(1)>> <> rest, token, _), do: {:ok, rest}
  def match(msg, _, _), do: {:error, msg}

  def pand(msg, [], _), do: {:ok, msg}
  def pand(msg, [h|t], rules) do
    with {:ok, rest} <- match(msg, h, rules),
         {:ok, rest} <- pand(rest, t, rules)
    do
      {:ok, rest}
    else
      _ -> {:error, msg}
    end
  end

  def por(msg, [], _), do: {:error, msg}
  def por(msg, [h|t], rules) do
    case match(msg, h, rules) do
      {:error, _} -> por(msg, t, rules)
      success -> success
    end
  end

  def print(x, label \\ nil) do
    IO.inspect(x, charlists: :as_list, limit: :infinity, label: label)
  end

  def parse([rules, msgs]), do: {parse_rules(rules), String.split(msgs, "\n", trim: true)}

  def parse_rules(lines) do
    lines
    |> String.split("\n")
    |> Enum.map(&parse_rule/1)
    |> Enum.into(%{})
  end

  def parse_rule(line) do
    with [idx, rule] <- String.split(line, ": "),
         idx <- String.to_integer(idx),
         ors <- rule |> String.split(" | "),
         ands <- Enum.map(ors, &parse_clause/1)
    do
      {idx, ands}
    end
  end

  def parse_clause("\"a\""), do: "a"
  def parse_clause("\"b\""), do: "b"
  def parse_clause(text), do: text |> String.split(" ") |> Enum.map(&String.to_integer/1)

  def load_modified(name \\ "day-19.input") do
    {rules, msgs} = load(name)

    rules = rules
            |> Map.put(8, [[42, 8], [42]])
            |> Map.put(11, [[42, 11, 31], [42, 31]])
    {rules, msgs}
  end

  def load(name \\ "day-19.input") do
    name
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> parse()
  end
end

defmodule Day19.Test do
  import Day19
  def test_build do
    rules = %{0 => "a", 1 => [0, 0], 2 => [[1], [0]], 3 => [[0, 3], [0]]}
    zero = build(0, rules) |> Map.get(0)
    IO.inspect(zero.("a"))

    one = build(1, rules) |> Map.get(1)
    IO.inspect(one.("aa"))

    two = build(2, rules) |> Map.get(2)
    IO.inspect(two.("aa"))

    three = build(3, rules) |> Map.get(3)
    IO.inspect(three.("aa"))
  end
end
