
defmodule Day4 do

  @required MapSet.new([
    "byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"
  ])

  @eyes MapSet.new([
    "amb", "blu", "brn", "gry", "grn", "hzl", "oth"
  ])

  def part_1 do
    load()
    |> Enum.map(&parse_passport/1)
    |> Enum.filter(&has_required_fields/1)
    |> Enum.count()
  end

  def part_2 do
    load()
    |> Enum.map(&parse_passport/1)
    |> Enum.filter(&has_required_fields/1)
    |> Enum.filter(&has_valid_fields/1)
    |> Enum.count()
  end

  def load do
    File.read!("day-4.input")
    |> String.split("\n\n", trim: true)
  end 

  def has_required_fields(attrs) do
    attrs
    |> Map.keys()
    |> Enum.into(MapSet.new())
    |> (&(MapSet.subset?(@required, &1))).()
  end

  def has_valid_fields(attrs) do
    in_range(attrs["byr"], 1920, 2002)
    and in_range(attrs["iyr"], 2010, 2020)
    and in_range(attrs["eyr"], 2020, 2030)
    and valid_height(String.reverse(attrs["hgt"]))
    and valid_hair_color(attrs["hcl"])
    and MapSet.member?(@eyes, attrs["ecl"])
    and Regex.match?(~r/^[0-9]{9}$/, attrs["pid"])
  end

  def in_range(field, low, high) do
    case Integer.parse(field) do
      {n, ""} when low <= n and n <= high -> true
      _ -> false
    end
  end

  def valid_height("mc" <> hgt), do: in_range(String.reverse(hgt), 150, 193)
  def valid_height("ni" <> hgt), do: in_range(String.reverse(hgt), 59, 76)
  def valid_height(_), do: false

  def valid_hair_color(color) do
    Regex.match?(~r/^#[a-f0-9]{6}$/, color)
  end

  def parse_passport(passport) do
    Regex.split(~r/[[:space:]]/, passport)
    |> Enum.map(&(String.split(&1, ":")))
    |> Map.new(fn [k,v] -> {k,v} end)
  end
end

