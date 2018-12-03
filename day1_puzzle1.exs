defmodule Day1Puzzle1 do
  def sum_file do
    file_name = 'day1_puzzle1_input.txt'
    result = File.stream!(file_name) |> Stream.map(&String.trim/1) |> Stream.map(&String.to_integer/1) |> Enum.reduce(&+/2)
    IO.puts result
  end
end

Day1Puzzle1.sum_file()
