defmodule Day8 do

  def part_1 do
    load()
    |> Enum.map(&parse_op/1)
    |> acc_before_loop(0, 0, MapSet.new())
  end

  def part_2 do
    ops = load() |> Enum.map(&parse_op/1)

    {op, x, pos} = ops
                   |> get_loop(0, [])
                   |> find_change(ops)
    ops
    |> List.replace_at(pos, {op, x})
    |> acc_before_loop(0, 0, MapSet.new())
  end

  def get_loop(ops, pos, path)do
    if pos in path do
      path
    else
      case Enum.at(ops, pos) do
        {"acc", _} -> get_loop(ops, pos + 1, [pos | path])
        {"jmp", x} -> get_loop(ops, pos + x, [pos | path])
        {"nop", _} -> get_loop(ops, pos + 1, [pos | path])
      end
    end
  end

  def find_change(path=[pos | tail], ops) do
    {op, x} = Enum.at(ops, pos)
    cond do
      op == "jmp" and terminates?(ops, pos + 1, path) -> {"nop", x, pos}
      op == "nop" and terminates?(ops, pos + x, path) -> {"jmp", x, pos}
      true -> find_change(tail, ops)
    end
  end

  def terminates?(ops, pos, seen) do
    cond do
      pos >= length(ops) -> true
      pos in seen -> false
      true ->
        case Enum.at(ops, pos) do
          {"acc", _} -> terminates?(ops, pos + 1, [pos | seen]) 
          {"jmp", x} -> terminates?(ops, pos + x, [pos | seen]) 
          {"nop", _} -> terminates?(ops, pos + 1, [pos | seen]) 
        end
    end
  end

  def acc_before_loop(ops, pos, acc, seen) do
    cond do
      pos >= length(ops) -> acc
      MapSet.member?(seen, pos) -> acc
      true -> 
        case Enum.at(ops, pos) do
          {"acc", x} -> acc_before_loop(ops, pos + 1, acc + x, MapSet.put(seen, pos))
          {"jmp", x} -> acc_before_loop(ops, pos + x, acc, MapSet.put(seen, pos))
          {"nop", _} -> acc_before_loop(ops, pos + 1, acc, MapSet.put(seen, pos))
        end
    end
  end

  def parse_op("jmp " <> int), do: {"jmp", String.to_integer(int)}
  def parse_op("acc " <> int), do: {"acc", String.to_integer(int)}
  def parse_op("nop " <> int), do: {"nop", String.to_integer(int)}

  def load do
    File.read!("day-8.input")
    |> String.split("\n", trim: true)
  end
end
