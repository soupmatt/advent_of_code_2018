defmodule Day10 do
  import NimbleParsec

  @doc """
  parses input record

  ## Examples

      iex> Day10.parse_record("position=< 9,  1> velocity=< 0,  2>")
      {{9, 1}, {0, 2}}

      iex> Day10.parse_record("position=< 7,  0> velocity=<-1,  0>")
      {{7, 0}, {-1, 0}}

      iex> Day10.parse_record("position=< 3, -2> velocity=<-1,  1>")
      {{3, -2}, {-1, 1}}

      iex> Day10.parse_record("position=< 6, 10> velocity=<-2, -1>")
      {{6, 10}, {-2, -1}}

      iex> Day10.parse_record("position=< 2, -4> velocity=< 2,  2>")
      {{2, -4}, {2, 2}}

      iex> Day10.parse_record("position=<-3, 11> velocity=< 1, -2>")
      {{-3, 11}, {1, -2}}

      iex> Day10.parse_record("position=<10, -3> velocity=<-1,  1>")
      {{10, -3}, {-1, 1}}

      iex> Day10.parse_record("position=< 31097, -41136> velocity=<-3,  4>")
      {{31097, -41136}, {-3, 4}}

      iex> Day10.parse_record("position=< 20827,  20741> velocity=<-2, -2>")
      {{20827, 20741}, {-2, -2}}

      iex> Day10.parse_record("position=<-51338, -30822> velocity=< 5,  3>")
      {{-51338, -30822}, {5, 3}}

  """
  def parse_record(input) do
    {:ok, [x, y, vx, vy | []], _, _, _, _} = record_parser(input)
    {{x, y}, {vx, vy}}
  end

  pos_num = integer(min: 1)
  neg_num = ignore(ascii_char('-')) |> integer(min: 1) |> map({:*, [-1]})
  num = ignore(optional(string(" "))) |> choice([pos_num, neg_num])

  defparsecp(
    :record_parser,
    ignore(string("position=<"))
    |> concat(num)
    |> ignore(string(","))
    |> ignore(repeat(string(" ")))
    |> concat(num)
    |> ignore(string("> velocity=<"))
    |> concat(num)
    |> ignore(string(","))
    |> ignore(repeat(string(" ")))
    |> concat(num)
    |> ignore(string(">"))
  )

  @doc """
  advances the point one unit forward

  ## Examples

      iex> Day10.advance_point({{9, 1}, {0, 2}})
      {{9, 3}, {0, 2}}

      iex> Day10.advance_point({{3, -2}, {-1, 1}})
      {{2, -1}, {-1, 1}}

      iex> Day10.advance_point({{-3, 11}, {1, -2}})
      {{-2, 9}, {1, -2}}

      iex> Day10.advance_point({{-3, 11}, {1, -2}}, 1)
      {{-2, 9}, {1, -2}}

      iex> Day10.advance_point({{6, 10}, {-2, -1}}, 2)
      {{2, 8}, {-2, -1}}

      iex> Day10.advance_point({{6, 10}, {-2, -1}}, 3)
      {{0, 7}, {-2, -1}}

  """
  def advance_point({{x, y}, {vx, vy}}, iterations \\ 1) when iterations >= 1 do
    {{x + vx * iterations, y + vy * iterations}, {vx, vy}}
  end

  def draw_grid_at_time(points, time \\ 0)

  def draw_grid_at_time([], _) do
    []
  end

  def draw_grid_at_time([_ | []], _) do
    ['#']
  end

  def draw_grid_at_time(points, 0) do
    {xmin, xmax, ymin, ymax} = get_grid_bounds(points)
    points = Enum.uniq_by(points, fn {point, _} -> point end) |> sort_points()
    draw_grid(xmax, xmin, xmax, ymax, ymin, ymax, points)
  end

  def draw_grid_at_time(points, time) do
    Enum.map(points, fn p -> advance_point(p, time) end)
    |> draw_grid_at_time(0)
  end

  def get_grid_bounds(points) do
    [{{xinit, yinit}, _} | remaining] = points

    Enum.reduce(remaining, {xinit, xinit, yinit, yinit}, fn {{x, y}, _},
                                                            {xmin, xmax, ymin, ymax} ->
      {min(xmin, x), max(xmax, x), min(ymin, y), max(ymax, y)}
    end)
  end

  def sort_points(points) do
    Enum.sort(points, fn
      {{_, y1}, _}, {{_, y2}, _} when y1 < y2 ->
        false

      {{_, y1}, _}, {{_, y2}, _} when y1 > y2 ->
        true

      {{x1, _}, _}, {{x2, _}, _} when x1 < x2 ->
        false

      _, _ ->
        true
    end)
  end

  defp draw_grid(x, xmin, xmax, y, ymin, ymax, points, current_row \\ [], rows \\ [])

  defp draw_grid(x, xmin, xmax, y, ymin, ymax, points, current_row, rows) when x < xmin do
    draw_grid(xmax, xmin, xmax, y - 1, ymin, ymax, points, [], [current_row | rows])
  end

  defp draw_grid(_, _, _, y, ymin, _, _, [], rows) when y < ymin do
    rows
  end

  defp draw_grid(x, xmin, xmax, y, ymin, ymax, [point | remaining], current_row, rows) do
    {{px, py}, _} = point

    if x == px and y == py do
      current_row = [?# | current_row]
      draw_grid(x - 1, xmin, xmax, y, ymin, ymax, remaining, current_row, rows)
    else
      current_row = [?. | current_row]
      draw_grid(x - 1, xmin, xmax, y, ymin, ymax, [point | remaining], current_row, rows)
    end
  end

  defp draw_grid(x, xmin, xmax, y, ymin, ymax, [], current_row, rows) do
    draw_grid(x - 1, xmin, xmax, y, ymin, ymax, [], [?. | current_row], rows)
  end

  def bounds_area({xlow, xhigh, ylow, yhigh}) do
    (xhigh - xlow + 1) * (yhigh - ylow + 1)
  end

  def find_minimum_bounds(points) do
    bounds = get_grid_bounds(points)
    find_minimum_bounds(points, bounds, bounds_area(bounds), 1)
  end

  def find_minimum_bounds(points, smallest_bounds, smallest_size, count) do
    advanced_points = Enum.map(points, &advance_point(&1))
    new_bounds = get_grid_bounds(advanced_points)
    new_size = bounds_area(new_bounds)

    if new_size < smallest_size do
      find_minimum_bounds(advanced_points, new_bounds, new_size, count + 1)
    else
      {count - 1, smallest_size, smallest_bounds, points}
    end
  end
end
