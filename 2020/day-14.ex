defmodule Day14 do
  use Bitwise, skip_operators: true

  @any "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

  def part_1 do
    load()
    |> interpret(@any, %{})
    |> Map.values()
    |> Enum.sum()
  end

  def part_2 do
    load()
    |> interpret2(@any, %{})
    |> Map.values()
    |> Enum.sum()
  end

  def test_2 do
    [
      ["mask", "000000000000000000000000000000X1001X"],
      ["mem", "42", "100"],
      ["mask", "00000000000000000000000000000000X0XX"],
      ["mem", "26", "1"],
    ]
    |> interpret2(@any, %{})
    |> IO.inspect()
    |> Map.values()
    |> Enum.sum()
  end 

  def test_3 do
    [
      ["mask", "00000000000000000000000000000XX10X1X"],
      ["mem", "42", "100"],
      ["mem", "8", "5"],
      ["mask", "00000000000000000000000000000000X1XX"],
      ["mem", "26", "2"],
      ["mem", "4", "1"],
    ]
    |> interpret2(@any, %{})
    |> Map.values()
    |> Enum.sum()
    |> IO.inspect()
    |> Kernel.==(632)
  end 

  def interpret2([], _, memory), do: memory
  def interpret2([["mask", m]|t], _, memory) do 
    mask = m
           |> IO.inspect()
           |> String.replace_leading("0", "")
           |> IO.inspect()
           |> String.reverse()
    interpret2(t, mask, memory)
  end
  def interpret2([["mem", addr, val]|t], pattern, memory) do
    val = String.to_integer(val)
    res = floating_mask(pattern, addr)
          |> variations()
          |> Enum.sort()
          |> Enum.into(%{}, &({String.to_integer(&1, 2), val}))

    interpret2(t, pattern, Map.merge(memory, res))
  end

  def variations(""), do: [""]
  def variations("X" <> rest) do
    rest
    |> variations()
    |> Enum.flat_map(&(["1" <> &1, "0" <> &1]))
  end
  def variations(<<char::bytes-size(1), rest::binary>>) do
    rest
    |> variations()
    |> Enum.map(&(char <> &1))
  end

  def floating_mask(pattern, value) do 
    value
    |> String.to_integer()
    |> Integer.to_string(2)
    |> String.reverse()
    |> merge(pattern)
    |> String.reverse()
  end

  def merge(s, ""), do: s
  def merge("", "0" <> rest), do: "0" <> merge("", rest)
  def merge("", "1" <> rest), do: "1" <> merge("", rest)
  def merge("", "X" <> rest), do: "X" <> merge("", rest)
  def merge(<<c1::bytes-size(1), r1::binary>>, "0" <> r2), do: c1 <> merge(r1, r2)
  def merge(<<_::bytes-size(1), r1::binary>>, "1" <> r2), do: "1" <> merge(r1, r2)
  def merge(<<_::bytes-size(1), r1::binary>>, "X" <> r2), do: "X" <> merge(r1, r2)

  def interpret([], _, memory), do: memory
  def interpret([["mask", m]|t], _, memory) do 
    interpret(t, String.replace_leading(m, "X", ""), memory)
  end
  def interpret([["mem", addr, val]|t], pattern, memory) do
    interpret(
      t,
      pattern,
      Map.put(memory, addr, mask(pattern, val))
    )
  end

  def mask(pattern, value) do
    {zeros, ""} = pattern |> String.replace("X", "1") |> Integer.parse(2)
    {ones, ""}  = pattern |> String.replace("X", "0") |> Integer.parse(2)

    value
    |> String.to_integer()
    |> Bitwise.band(zeros)
    |> Bitwise.bor(ones)
  end

  def load do
    File.read!("day-14.input")
    |> String.split("\n", trim: true)
    |> Enum.map(&parse/1)
  end

  def parse(s="ma" <> _) do
    String.split(s, " = ", trim: true)
  end

  def parse(s="me" <> _) do
    s
    |> String.replace(["[", "]", "="], " ")
    |> String.split(" ", trim: true)
  end

  def test do
    [
    ["mask", "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X"],
    ["mem", "8", "11"],
    ["mem", "7", "101"],
    ["mem", "8", "0"],
    ]
    |> interpret(@any, %{})
    |> Map.values()
    |> Enum.sum()
  end
end
