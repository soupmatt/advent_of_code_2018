defmodule Day12 do
  import NimbleParsec

  @doc """

  ## Examples

      iex> Day12.parse_initial_state("initial state: #..#.#..##......###...###")
      "#..#.#..##......###...###"

  """
  def parse_initial_state(string) do
    {:ok, [result], _, _, _, _} = initial_state_parser(string)
    result
  end

  my_ascii_strings = repeat(ascii_string([?#, ?.], min: 1))

  defparsecp(
    :initial_state_parser,
    ignore(string("initial state: ")) |> concat(my_ascii_strings)
  )

  @doc """

  ## Examples

      iex> Day12.parse_rule("...## => #")
      ["...##", "#"]

      iex> Day12.parse_rule("..#.. => #")
      ["..#..", "#"]

      iex> Day12.parse_rule(".#.## => #")
      [".#.##", "#"]

      iex> Day12.parse_rule("..... => .")
      [".....", "."]

      iex> Day12.parse_rule("#..## => .")
      ["#..##", "."]

  """
  def parse_rule(string) do
    {:ok, result, _, _, _, _} = rule_parser(string)
    result
  end

  defparsecp(
    :rule_parser,
    concat(my_ascii_strings, ignore(string(" => "))) |> concat(my_ascii_strings)
  )

  @doc """

  ## Examples

      iex> Day12.compile_rules([
      ...> ["...##", "#"],
      ...> ["..#..", "#"],
      ...> [".#.##", "#"],
      ...> [".....", "."],
      ...> ["#..##", "."],
      ...> ])
      %{
        "...##" => "#",
        "..#.." => "#",
        ".#.##" => "#",
        "....." => ".",
        "#..##" => ".",
      }
  """
  def compile_rules(rules) do
    Enum.reduce(rules, %{}, fn [k, v], acc ->
      Map.put(acc, k, v)
    end)
  end

  def advance_generations(state, rules, count \\ 1, first_pot \\ 0)

  def advance_generations(state, _rules, 0, pot) do
    {state, pot}
  end

  def advance_generations(state, rules, count, pot) when count > 0 do
    {new_state, pot} = advance_generations1(state, rules, pot)
    advance_generations(new_state, rules, count - 1, pot)
  end

  defp advance_generations1(
         <<first::binary-size(1), second::binary-size(1), rest::binary>>,
         rules,
         pot
       ) do
    acc = ""
    first_check = Map.get(rules, "...." <> first, ".")
    second_check = Map.get(rules, "..." <> first <> second, ".")

    {acc, pot} =
      if first_check == "#" do
        acc = acc <> first_check
        pot = pot - 2

        if second_check == "#" do
          {acc <> second_check, pot - 2}
        else
          {acc <> ".", pot - 2}
        end
      else
        if second_check == "#" do
          {acc <> second_check, pot - 1}
        else
          {acc, pot}
        end
      end

    advance_generations1(".." <> first <> second <> rest, rules, acc, pot)
  end

  defp advance_generations1(<<to_match::binary-size(5), rest::binary>>, rules, acc, pot) do
    next = Map.get(rules, to_match, ".")

    <<_first::binary-size(1), head::binary>> = to_match
    advance_generations1(head <> rest, rules, acc <> next, pot)
  end

  defp advance_generations1(<<to_match::binary-size(4)>>, rules, acc, pot) do
    next = Map.get(rules, to_match <> ".", ".")

    <<_first::binary-size(1), head::binary>> = to_match
    advance_generations1(head, rules, acc <> next, pot)
  end

  defp advance_generations1(<<to_match::binary-size(3)>>, rules, acc, pot) do
    next = Map.get(rules, to_match <> "..", ".")

    <<_first::binary-size(1), head::binary>> = to_match
    advance_generations1(head, rules, acc <> next, pot)
  end

  defp advance_generations1(<<first::binary-size(1), second::binary-size(1)>>, rules, acc, pot) do
    first_match = Map.get(rules, first <> second <> "...", ".")
    second_match = Map.get(rules, second <> "....", ".")

    acc =
      if first_match == "#" do
        acc = acc <> "#"

        if second_match == "#" do
          acc <> "#"
        else
          acc
        end
      else
        if second_match == "#" do
          acc <> ".#"
        else
          acc
        end
      end

    {acc, pot}
  end

  @doc """

  ## Examples

      iex> Day12.count_plants("#")
      0

      iex> Day12.count_plants("###")
      3

      iex> Day12.count_plants(".")
      0

      iex> Day12.count_plants(".......")
      0

      iex> Day12.count_plants("##..#..#####.")
      50

      iex> Day12.count_plants("##..#..#####.", 1)
      58

      iex> Day12.count_plants("##..#..#####.", -2)
      34

      iex> Day12.count_plants(".#.#..#.###.")
      37

  """
  def count_plants(state, first_pot \\ 0) do
    count_plants(state, first_pot, 0)
  end

  defp count_plants(<<"." <> rest::binary>>, pot_number, acc) do
    count_plants(rest, pot_number + 1, acc)
  end

  defp count_plants(<<"#" <> rest::binary>>, pot_number, acc) do
    count_plants(rest, pot_number + 1, acc + pot_number)
  end

  defp count_plants("", _pot_number, acc) do
    acc
  end

  def collect_generations(initial_state, rules, count) do
    Enum.reduce(1..count, [{initial_state, 0}], fn _, [{initial, pot} | acc] ->
      [Day12.advance_generations(initial, rules, 1, pot), {initial, pot} | acc]
    end)
    |> Enum.reverse()
  end
end
