defmodule Day2Puzzle2 do
  def find_result do
    file_name = 'day2_puzzle1_input.txt'
    result = File.stream!(file_name) |>
      Stream.map(&String.trim/1) |> find_common_letters
    IO.puts "we have a result!"
    IO.puts result
  end

  def find_common_letters(strings) do
    Enum.reduce_while(strings, [], &find_common_letters/2)
  end

  def find_common_letters(str, []) do
    {:cont, [str]}
  end

  def find_common_letters(str, acc) do
    result = Enum.reduce_while(acc, str, fn i, str ->
      case compare_strings(i, str) do
        {:ok, result} ->
          {:halt, result}
        _ ->
          {:cont, str}
      end
    end)
    if result == str do
      {:cont, acc ++ [str]}
    else
      {:halt, result}
    end
  end

  def compare_strings(left, right) do
    compare_strings(left, right, 0, "")
  end

  def compare_strings(_, _, count, _) when count > 1 do
    false
  end

  def compare_strings("", "", 1, collected) do
    {:ok, collected}
  end

  def compare_strings("", "", 0, _) do
    false
  end

  def compare_strings(left, right, count, collected) do
    {lfirst, lrest} = String.next_grapheme(left)
    {rfirst, rrest} = String.next_grapheme(right)
    if lfirst == rfirst do
      compare_strings(lrest, rrest, count, collected <> lfirst)
    else
      compare_strings(lrest, rrest, count+1, collected)
    end
  end
end

ExUnit.start()

defmodule Day2Puzzle2Test do
  use ExUnit.Case

  import Day2Puzzle2

  test "#find_common_letters" do
    codes = ["abcde", "fghij", "klmno", "pqrst", "fguij", "axcye", "wvxyz"]

    assert find_common_letters(codes) == "fgij"
  end

  test "#compare_strings" do
    assert compare_strings("aaa", "aaa") == false
    assert compare_strings("aab", "aaa") == {:ok, "aa"}
    assert compare_strings("abcb", "abca") == {:ok, "abc"}
    assert compare_strings("abcdef", "abcdef") == false
    assert compare_strings("aacdef", "abcdaf") == false
  end

end

Day2Puzzle2.find_result()
