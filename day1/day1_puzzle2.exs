defmodule Day1Puzzle2 do
  def find_first_repeat(stream) do
    {_, result} = Enum.flat_map_reduce(stream, {MapSet.new([0]), 0}, &find_repeat/2)
    result
  end

  def find_repeat(next_element, {previous_frequencies, current_frequency}) do
    next_frequency = next_element + current_frequency
    if MapSet.member?(previous_frequencies, next_frequency) do
      {:halt, next_frequency}
    else
      {[next_element], {MapSet.put(previous_frequencies, next_frequency), next_frequency}}
    end
  end

  def find_result do
    file_name = 'day1_puzzle1_input.txt'
    stream = File.stream!(file_name) |> Stream.map(&String.trim/1) |> Stream.map(&String.to_integer/1) |> Stream.cycle()
    result = find_first_repeat(stream)
    IO.puts "we have a result!"
    IO.puts result
  end
end

ExUnit.start()

defmodule Day1Puzzle2Test do
  use ExUnit.Case

  import Day1Puzzle2

  test "provided examples" do
    assert find_first_repeat(Stream.cycle([+1, -1])) == 0
    assert find_first_repeat(Stream.cycle([+3, +3, +4, -2, -4])) == 10
    assert find_first_repeat(Stream.cycle([-6, +3, +8, +5, -6])) == 5
    assert find_first_repeat(Stream.cycle([+7, +7, -2, -7, -4])) == 14
  end

  test "#find_repeat" do
    assert find_repeat(1, {MapSet.new([0]), 0}) == {[1], {MapSet.new([0, 1]), 1}}
  end
end

Day1Puzzle2.find_result()
