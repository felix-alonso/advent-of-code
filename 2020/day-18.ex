defmodule Day18 do

  def part_1, do: load() |> Enum.map(&interpret/1) |> Enum.sum()
  def part_2, do: load() |> Enum.map(&interpret2/1) |> Enum.sum()

  def interpret(text), do: text |> lex() |> parse() |> eval()
  def interpret2(text), do: text |> lex() |> parse() |> wrap() |> eval()

  def lex(""), do: []
  def lex(" " <> rest), do: lex(rest)
  def lex(<<n::bytes-size(1)>> <> rest) when n in ["(", ")", "+", "*"], do: [n|lex(rest)]
  def lex(<<n::bytes-size(1)>> <> rest), do: [String.to_integer(n)|lex(rest)]

  def parse(tokens=["("|_]), do: parse(match_parens(tokens, []))
  def parse([n|rest]), do: [parse(n)|parse(rest)]
  def parse(n), do: n

  def match_parens(["("|t], stack), do: match_parens(t, [[]|stack])
  def match_parens([")"|t], [c,p|rest]), do: match_parens(t, [[parse(Enum.reverse(c))|p]|rest])
  def match_parens([")"|rest], [group]), do: [Enum.reverse(group)|rest]
  def match_parens([n|t], [group|rest]), do: match_parens(t, [[n|group]|rest])

  def wrap([]), do: []
  def wrap([left, "+", right|rest]), do: wrap([[wrap(left), "+", wrap(right)]|rest])
  def wrap([left, "*", right|rest]), do: [wrap(left), "*"| wrap([wrap(right)|rest])]
  def wrap([n]), do: [n]
  def wrap(n), do: n

  def eval(prev, []), do: prev
  def eval(prev, ["+", n|rest]), do: eval(prev + eval(n), rest)
  def eval(prev, ["*", n|rest]), do: eval(prev * eval(n), rest)
  def eval([n, "+", m|rest]), do: eval(eval(n) + eval(m), rest)
  def eval([n, "*", m|rest]), do: eval(eval(n) * eval(m), rest)
  def eval([l=[_|_]]), do: eval(l)
  def eval(n), do: n

  def load, do: File.read!("day-18.input") |> String.split("\n", trim: true)
end

