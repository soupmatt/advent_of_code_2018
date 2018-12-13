# Caching of results and detecting that there was a cycle was heavily inspired by
# https://github.com/sasa1977/aoc/blob/78b6d746d1653a281cbc5b7ed8528b235cc12586/lib/2018/day12.ex

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

  def advance_generations(state, rules, count \\ 1, first_pot \\ 0, cache \\ %{})

  def advance_generations(state, _rules, 0, pot, _cache) do
    {state, pot}
  end

  def advance_generations(old_state, rules, count, old_pot, cache) when count > 0 do
    case transition(old_state, cache, count) do
      {:cycle, cycle_steps, cycle_position_offset} ->
        num_cycles = div(count, cycle_steps)
        new_pot = old_pot + cycle_position_offset * num_cycles
        advance_generations(old_state, rules, count - num_cycles * cycle_steps, new_pot, cache)

      {new_state, steps, offset} ->
        advance_generations(new_state, rules, count - steps, old_pot + offset, cache)

      nil ->
        {new_state, new_pot} = advance_generations1(old_state, rules, old_pot)

        advance_generations(
          new_state,
          rules,
          count - 1,
          new_pot,
          Map.put(cache, old_state, {new_state, new_pot - old_pot})
        )
    end
  end

  defp transition(initial_state, cache, max_steps, steps \\ 0, offset \\ 0, current_state \\ nil)

  defp transition(_initial_state, _cache, max_steps, max_steps, offset, current_state),
    do: {current_state, max_steps, offset}

  defp transition(initial_state, cache, max_steps, steps, offset, current_state) do
    case Map.fetch(cache, current_state || initial_state) do
      {:ok, {^initial_state, next_offset}} ->
        {:cycle, steps + 1, offset + next_offset}

      {:ok, {next_state, next_offset}} ->
        transition(initial_state, cache, max_steps, steps + 1, offset + next_offset, next_state)

      :error ->
        if not is_nil(current_state), do: {current_state, steps, offset}, else: nil
    end
  end

  defp trim_state({<<".", rest::binary>>, pot}) do
    trim_state({rest, pot + 1})
  end

  defp trim_state(result), do: result

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

    trim_state({acc, pot})
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
