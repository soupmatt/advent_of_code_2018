defmodule Day2Puzzle1 do
  def letters_match(str) do
    letter_counts = string_counter(str, Map.new())
    counts = Map.values(letter_counts)
    {Enum.member?(counts, 2), Enum.member?(counts, 3)}
  end

  defp string_counter(str, map) do
    case String.next_grapheme(str) do
      {next, rest} ->
        map = increment_count_in_map(next, map)
        string_counter(rest, map)
      nil ->
        map
      end
  end

  defp increment_count_in_map(c, map) do
    Map.update(map, c, 1, fn x -> x + 1 end)
  end

  def find_result do
    file_name = 'day2_puzzle1_input.txt'
    counts = File.stream!(file_name) |>
      Stream.map(&String.trim/1) |>
      Stream.map(&letters_match/1) |>
      Enum.reduce(Map.new(), fn i, acc ->
        {two, three} = i
        acc = if two == true do
          Map.update(acc, 2, 1, fn x -> x + 1 end)
        else
          acc
        end
        acc = if three == true do
          Map.update(acc, 3, 1, fn x -> x + 1 end)
        else
          acc
        end
        acc
      end)
    twos = Map.fetch!(counts, 2)
    threes = Map.fetch!(counts, 3)
    IO.puts "we have a result!"
    IO.puts twos * threes
  end
end

ExUnit.start()

defmodule Day2Puzzle1Test do
  use ExUnit.Case

  import Day2Puzzle1

  test "#letters_match" do
    assert letters_match("abcdef") == {false, false}
    assert letters_match("bababc") == {true, true}
    assert letters_match("abbcde") == {true, false}
    assert letters_match("abcccd") == {false, true}
    assert letters_match("aabcdd") == {true, false}
    assert letters_match("abcdee") == {true, false}
    assert letters_match("ababab") == {false, true}
  end
end

Day2Puzzle1.find_result()
