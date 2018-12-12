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

    hundreds =
      to_charlist(mult) |> Enum.at(-3) |> List.wrap() |> to_string() |> String.to_integer()

    answer = hundreds - 5
    answer
  end

  @doc """

  ## Examples

      iex> Day11.max_power_point_for_size_3(18)
      {{33,45}, 29}

      iex> Day11.max_power_point_for_size_3(42)
      {{21,61}, 30}

  """
  def max_power_point_for_size_3(grid_serial_number) do
    current_max_power = power_for_location(1, 1, grid_serial_number)
    max_power_point_for_size_3(grid_serial_number, {2, 1}, {1, 1}, current_max_power)
  end

  defp max_power_point_for_size_3(
         grid_serial_number,
         {x, y},
         current_max_point,
         current_max_power
       )
       when x > 298 do
    max_power_point_for_size_3(
      grid_serial_number,
      {0, y + 1},
      current_max_point,
      current_max_power
    )
  end

  defp max_power_point_for_size_3(
         _grid_serial_number,
         {_x, y},
         current_max_point,
         current_max_power
       )
       when y > 298 do
    {current_max_point, current_max_power}
  end

  defp max_power_point_for_size_3(
         grid_serial_number,
         {x, y},
         current_max_point,
         current_max_power
       ) do
    new_max_power = power_for_location(x, y, grid_serial_number)

    if new_max_power > current_max_power do
      max_power_point_for_size_3(grid_serial_number, {x + 1, y}, {x, y}, new_max_power)
    else
      max_power_point_for_size_3(
        grid_serial_number,
        {x + 1, y},
        current_max_point,
        current_max_power
      )
    end
  end

  @doc """

  ## Examples

      iex> Day11.power_for_location(33, 45, 18)
      29

      iex> Day11.power_for_location(90, 269, 18, 16)
      113

  """
  def power_for_location(x, y, grid_serial_number, max_size \\ 3)

  def power_for_location(x, y, grid_serial_number, 1) do
    cell_power(x, y, grid_serial_number)
  end

  def power_for_location(x, y, grid_serial_number, max_size) do
    initial_power = cell_power(x, y, grid_serial_number)

    result =
      Enum.reduce(2..max_size, initial_power, fn size, prev_power ->
        power_for_next_size(x, y, prev_power, size, grid_serial_number)
      end)

    result
  end

  defp power_for_next_size(x, y, prev_power, size, grid_serial_number) when size >= 2 do
    x_power =
      for x1 <- x..(x + size - 1) do
        cell_power(x1, y + size - 1, grid_serial_number)
      end
      |> Enum.sum()

    y_power =
      for y1 <- y..(y + size - 2) do
        cell_power(x + size - 1, y1, grid_serial_number)
      end
      |> Enum.sum()

    prev_power + x_power + y_power
  end

  def max_power_point(grid_serial_number) do
    {:ok, result} =
      for x <- 1..300, y <- 1..300 do
        {x, y}
      end
      |> Task.async_stream(fn {x, y} ->
        {power, size} = max_power_for_location_by_size(x, y, grid_serial_number)
        {{x, y, size}, power}
      end)
      |> Enum.max_by(fn {:ok, {_, power}} -> power end)

    result
  end

  @doc """

  ## Examples

      iex> Day11.max_power_for_location_by_size(90, 269, 18)
      {113, 16}

      iex> Day11.max_power_for_location_by_size(232, 251, 42)
      {119, 12}

  """
  def max_power_for_location_by_size(x, y, grid_serial_number) when x < 300 and y < 300 do
    size_range = 2..(301 - max(x, y))
    initial_power = power_for_location(x, y, grid_serial_number, 1)

    {result, _} =
      Enum.reduce(size_range, {{initial_power, 1}, initial_power}, fn size,
                                                                      {{current_power,
                                                                        current_size},
                                                                       prev_power} ->
        new_power = power_for_next_size(x, y, prev_power, size, grid_serial_number)

        if new_power > current_power do
          {{new_power, size}, new_power}
        else
          {{current_power, current_size}, new_power}
        end
      end)

    result
  end

  def max_power_for_location_by_size(x, y, grid_serial_number) do
    {power_for_location(x, y, grid_serial_number, 1), 1}
  end
end
