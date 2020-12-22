defmodule Day20.Tile do
  alias Day20.Tile

  defstruct [:id, :tile, flipped: false, rotations: 0]

  def row(%{tile: tile}, n), do: Enum.at(tile, n)
  def row(tile, n), do: Enum.at(tile, n)

  def column(%{tile: tile}, n), do: Enum.map(tile, &(Enum.at(&1, n)))
  def column(tile, n), do: Enum.map(tile, &(Enum.at(&1, n)))

  def side(tile, :top), do: row(tile, 0)
  def side(tile, :left), do: column(tile, 0)
  def side(tile, :right), do: column(tile, -1)
  def side(tile, :bottom), do: row(tile, -1)

  def flip(t=%{tile: tile, flipped: flipped}), 
    do: %{t | tile: Enum.map(tile, &Enum.reverse/1), flipped: not flipped}

  def rotate(t=%{tile: tile, rotations: r}, n), 
    do: %{t | tile: rotate(tile, n), rotations: rem(r + n, 4)}
  def rotate(tile, 0), do: tile
  def rotate(tile, n) do 
    0..(length(tile) - 1)
    |> Enum.map(&(tile |> column(&1) |> Enum.reverse()))
    |> rotate(n - 1)
  end

  def adjacent?(%{id: id1}, %{id: id1}), do: []
  def adjacent?(tile1, tile2) do
    tile2
    |> variants() 
    |> Enum.map(&(align(tile1, &1)))
    |> Enum.filter(&(&1 != nil))
    |> Enum.take(1)
  end

  def variants(tile) do
    rotations = Enum.map(0..3, &(rotate(tile, &1)))
    flipped = Enum.map(rotations, &(flip(&1)))

    rotations ++ flipped
  end

  def align(%{tile: t1}, tile2=%{tile: t2}) do
    cond do
      side(t1, :left) == side(t2, :right) -> [:left, tile2]
      side(t1, :right) == side(t2, :left) -> [:right, tile2]
      side(t1, :top) == side(t2, :bottom) -> [:top, tile2]
      side(t1, :bottom) == side(t2, :top) -> [:bottom, tile2]
      true -> nil
    end
  end

  def interior(t=%{tile: tile}) do
    tile = tile
           |> List.delete_at(0)
           |> List.delete_at(-1)
           |> Enum.map(&(List.delete_at(&1, 0)))
           |> Enum.map(&(List.delete_at(&1, -1)))

    %{t | tile: tile}
  end

  def parse_tile("Tile " <> <<id::bytes-size(4)>> <> ":\n" <> tile) do
    %Tile{id: String.to_integer(id), tile: as_2d(tile)}
  end

  def as_2d(text) do
    text
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end
end

defmodule Day20 do
  import Day20.Tile

  @reg1 ~r(\A.#)
  @reg2 ~r(\A###....##....##....#)
  @reg3 ~r(\A...#..#..#..#..#..#)
  def part_1 do
    [h|t] = load() 
    tiles = [h|t] |> Enum.map(&({&1.id, &1})) |> Enum.into(%{})

    match_all([h.id], tiles, %{})
    |> corners()
    |> Enum.map(fn {id, _} -> id end)
    |> Enum.reduce(1, &Kernel.*/2)
  end

  def part_2 do
    [h|t] = load() 
    tiles = [h|t] |> Enum.map(&({&1.id, &1})) |> Enum.into(%{})

    # build lookup of tile to adjacent tiles
    matched = match_all([h.id], tiles, %{})

    # find a corner to start
    [{corner, _}] = corners(matched, 1)
    origin = Map.get(tiles, corner)

    # build the map from the corner
    map = align_all([{origin, 0, 0}], tiles, matched, %{})
          |> join_map()

    rotations = 0..3 |> Enum.map(&(rotate_map(map, &1)))
    flipped = rotations |> Enum.map(&flip_map/1)
    maps = rotations ++ flipped

    serpents = maps |> Enum.map(&find_serpent/1) |> Enum.max()
    IO.puts("serpents: #{serpents}")

    waves = count_waves(map)
    IO.puts("possible waves: #{waves}")
    IO.inspect(waves - (serpents * 15), label: "waves")
  end

  def count_waves(map) do
    map
    |> Enum.map(fn row -> row |> String.graphemes() |> Enum.count(&(&1 == "#")) end)
    |> Enum.sum()
  end

  def flip_map(map), do: map |> Enum.map(&String.reverse/1)

  def rotate_map(map, n) do
    map
    |> Enum.map(&String.graphemes/1)
    |> rotate(n)
    |> Enum.map(&(Enum.join(&1, "")))
  end

  def find_serpent(map) do
    import String, only: [reverse: 1]
    map
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(fn [l1, l2, l3] -> 
      count_serpents(reverse(l1), reverse(l2), reverse(l3))
    end)
    |> Enum.sum()
  end

  def count_serpents(l1, _, _) when length(l1) < 20, do: 0
  def count_serpents(l1, l2="###" <> _, l3) do
    with r when is_list(r) <- Regex.run(@reg2, l2),
         r when is_list(r) <- Regex.run(@reg3, l3),
         r when is_list(r) <- Regex.run(@reg1, l1)  # least specific line last
    do
      1 + jump(l1, l2, l3)
    else
      _ -> jump(l1, l2, l3)
    end
  end
  def count_serpents(l1, l2, l3), do: jump(l1, l2, l3)

  def jump(l1, l2, l3) do
    with {skip, _} <- :binary.match(l2, "###") do
      count_serpents(slice(l1, skip), slice(l2, skip), slice(l3, skip))
    else
      _ -> 0
    end
  end

  def slice(text, skip \\ 1), do: String.slice(text, max(1, skip)..-1)

  def join_map(map) do
    map
    |> Enum.group_by(fn {{_, r}, _} -> r end, fn {{c, _}, t} -> {c, t} end)
    |> Enum.sort(fn {r1, _}, {r2, _} -> r1 >= r2 end)
    |> Enum.map(fn {_, tiles} -> Enum.sort(tiles) end)
    |> Enum.map(fn row -> Enum.reduce(row, &join_tiles/2) end)
    |> Enum.reduce(&Enum.concat/2)
    |> Enum.map(&Enum.join()/1)
    #|> Enum.join("\n")
  end

  def join_tiles([], []), do: [] 
  def join_tiles([h1|t1], [h2|t2]), do: [h1 ++ h2 | join_tiles(t1, t2)] 
  def join_tiles({_, %{tile: t1}}, {_, %{tile: t2}}), do: join_tiles(t1, t2)
  def join_tiles({_, %{tile: t1}}, t2), do: join_tiles(t1, t2)

  def align_all([], _, _, placed), do: placed
  def align_all([{h, x, y}|t], tiles, matched, placed) do
    if Map.has_key?(placed, {x, y}) do
      align_all(t, tiles, matched, placed)
    else
      placed = Map.put(placed, {x, y}, interior(h))

      ms = Map.get(matched, h.id)
           |> Enum.map(&(Map.get(tiles, &1)))
           |> Enum.map(&(orient(h, &1, x, y)))

      align_all(ms ++ t, tiles, matched, placed)
    end
  end

  def orient(tile1, tile2, x, y) do
    [[dir, tile2]] = adjacent?(tile1, tile2)
    case dir do
      :top -> {tile2, x, y - 1}
      :left -> {tile2, x + 1, y}
      :right -> {tile2, x - 1, y}
      :bottom -> {tile2, x, y + 1}
    end
  end

  def corners(matches, n \\ 4) do 
    matches 
    |> Stream.filter(fn {_, ms} -> length(ms) == 2 end)
    |> Enum.take(n)
  end

  def match_all([], _, lookup), do: lookup
  def match_all([h|t], tiles, lookup) do
    {tile, tiles} = Map.pop(tiles, h)

    if tile == nil do
      match_all(t, tiles, lookup)
    else
      ms = matches(tile, Map.values(tiles))
      lookup = update_lkp(lookup, ms, h)
               |> Map.update(h, ms, &(Enum.uniq(ms ++ &1)))

      match_all(ms ++ t, tiles, lookup)
    end
  end

  def update_lkp(lookup, [], _), do: lookup
  def update_lkp(lookup, [h|t], id) do
    lookup
    |> Map.update(h, [id], &(Enum.uniq([id|&1])))
    |> update_lkp(t, id)
  end

  def matches(tiles), do: Stream.map(tiles, &(matches(&1, tiles)))
  def matches(tile, tiles) do
    for t <- variants(tile) do
      tiles 
      |> Stream.map(&(adjacent?(t, &1))) 
      |> Stream.filter(&(&1 != []))
      |> Enum.take(4)
      |> Enum.map(fn [[_, %{id: id}]] -> id end)
    end
    |> Enum.reduce(fn m1, m2 -> 
      if length(m2) > length(m1), do: m2, else: m1 
    end)
  end

  def parse(lines) do
    lines
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_tile/1)
  end

  def load(name \\ "day-20.input"), do: File.read!(name) |> parse()
end

