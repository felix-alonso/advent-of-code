defmodule Day22 do

  def part_1 do
    [player1, player2] = load()
    
    {_, deck} = combat(player1, player2)
    score(deck)
  end

  def part_2 do
    [player1, player2] = load()
    
    {_, deck} = rec_combat(player1, player2, MapSet.new())
    score(deck)
  end

  def score(deck) do
    deck
    |> :queue.to_list()
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {v, idx} -> v * idx end)
    |> Enum.sum()
  end

  def rec_combat(p1, {[], []}, _), do: {:player1, p1}
  def rec_combat({[], []}, p2, _), do: {:player2, p2}
  def rec_combat(p1, p2, seen) do
    if MapSet.member?(seen, {p1, p2}) do
      {:player1, p1}
    else
      seen = MapSet.put(seen, {p1, p2})

      {{:value, c1}, p1} = :queue.out(p1)
      {{:value, c2}, p2} = :queue.out(p2)

      winner = if c1 <= :queue.len(p1) and c2 <= :queue.len(p2) do
        {subp1, _} = :queue.split(c1, p1)
        {subp2, _} = :queue.split(c2, p2)

        {player, _} = rec_combat(subp1, subp2, MapSet.new())
        player
      else
        if c1 > c2, do: :player1, else: :player2
      end

      p1 = 
        if winner == :player1, do: push_both(p1, c1, c2), else: p1

      p2 = 
        if winner == :player2, do: push_both(p2, c2, c1), else: p2

      rec_combat(p1, p2, seen)
    end
  end

  def combat(p1, {[], []}), do: {:player1, p1}
  def combat({[], []}, p2), do: {:player2, p2}
  def combat(p1, p2) do
    {{:value, c1}, p1} = :queue.out(p1)
    {{:value, c2}, p2} = :queue.out(p2)

    p1 = 
      if c1 > c2, do: push_both(p1, c1, c2), else: p1

    p2 = 
      if c1 < c2, do: push_both(p2, c2, c1), else: p2

    combat(p1, p2)
  end

  def push_both(q, c1, c2) do
    q = :queue.in(c1, q)
    :queue.in(c2, q)
  end

  def load, do: File.read!("day-22.input") |> parse()

  def parse(lines) do
    lines
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_deck/1)
  end

  def parse_deck(lines) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
    |> :queue.from_list()
  end
end
