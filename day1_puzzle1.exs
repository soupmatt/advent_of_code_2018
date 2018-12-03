defmodule Day1Puzzle1 do
  use Agent

  def start_sum() do
    Agent.start_link(fn -> 0 end)
  end

  def get_sum(sum) do
    Agent.get(sum, fn acc -> acc end)
  end

  def add_digits(sum, "+" <> val) do
    digit = String.to_integer(val)
    Agent.update(sum, fn x -> x + digit end)
  end

  def add_digits(sum, "-" <> val) do
    digit = String.to_integer(val)
    Agent.update(sum, fn x -> x - digit end)
  end

  defp add_file_line(line, sum) do
    add_digits(sum, line)
    sum
  end

  def sum_file do
    file_name = 'day1_puzzle1_input.txt'
    {:ok, sum} = start_sum()
    stream = File.stream!(file_name) |> Stream.map(&String.trim/1)
    result = Enum.reduce(stream, sum, &add_file_line/2)
    IO.puts "we have a result!"
    IO.puts get_sum(result)
  end

end

ExUnit.start()

defmodule Day1Puzzle1Test do
  use ExUnit.Case

  import Day1Puzzle1

  setup do
    {:ok, sum} = start_sum()
    %{sum: sum}
  end

  test "#start_sum returns an agent with sum zero", %{sum: sum} do
    assert get_sum(sum) == 0
  end

  test "#add_digits adds positive numbers", %{sum: sum} do
    assert get_sum(sum) == 0

    add_digits(sum, "+2")
    assert get_sum(sum) == 2
  end

  test "#add_digits subtracts negative numbers", %{sum: sum} do
    assert get_sum(sum) == 0

    add_digits(sum, "-3")
    assert get_sum(sum) == -3
  end

  test "#add_digits sums a bunch of numbers", %{sum: sum} do
    assert get_sum(sum) == 0

    add_digits(sum, "-3")
    add_digits(sum, "+5")
    add_digits(sum, "-42")
    add_digits(sum, "+15")
    add_digits(sum, "+53")
    add_digits(sum, "-8")
    assert get_sum(sum) == 20
  end
end

Day1Puzzle1.sum_file()
