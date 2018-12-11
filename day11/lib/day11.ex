defmodule Day11 do

  @doc """
  calculate cell power

  ## Examples

      iex> Day11.cell_power(3, 5, 8)
      4

      iex> Day11.cell_power(122, 79, 57)
      -5

      iex> Day11.cell_power(217, 196, 39)
      0

      iex> Day11.cell_power(101, 153, 71)
      4

  """
  def cell_power(x, y, grid_serial_number) do
    rack_id = x + 10
    start = rack_id * y
    next = start + grid_serial_number
    mult = next * rack_id
    hundreds = to_charlist(mult) |> Enum.at(-3) |> List.wrap() |> to_string() |> String.to_integer()
    answer = hundreds - 5
    answer
  end

  @doc """

  ## Examples

      iex> Day11.max_power_point(18)
      {{33,45}, 29}

      iex> Day11.max_power_point(42)
      {{21,61}, 30}

  """
  def max_power_point(grid_serial_number) do
    current_max_power = power_for_location(0, 0, grid_serial_number)
    max_power_point(grid_serial_number, {1, 0}, {0, 0}, current_max_power)
  end

  defp max_power_point(grid_serial_number, {x, y}, current_max_point, current_max_power) when x > 298 do
    max_power_point(grid_serial_number, {0, y+1}, current_max_point, current_max_power)
  end

  defp max_power_point(_grid_serial_number, {_x, y}, current_max_point, current_max_power) when y > 298 do
    {current_max_point, current_max_power}
  end

  defp max_power_point(grid_serial_number, {x, y}, current_max_point, current_max_power) do
    new_max_power = power_for_location(x, y, grid_serial_number)
    if new_max_power > current_max_power do
      max_power_point(grid_serial_number, {x+1, y}, {x, y}, new_max_power)
    else
      max_power_point(grid_serial_number, {x+1, y}, current_max_point, current_max_power)
    end
  end

  defp power_for_location(x, y, grid_serial_number) do
    for x <- x..x+2, y <- y..y+2 do
      cell_power(x, y, grid_serial_number)
    end
    |> Enum.sum()
  end
end
