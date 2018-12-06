defmodule Day6 do
  import NimbleParsec

  defparsecp(:coordinate, integer(min: 1) |> ignore(string(", ")) |> integer(min: 1))

  @doc """
  parses input coordinates

  ## Examples

      iex> Day6.parse_coordinates([
      ...>   "1, 1",
      ...>   "1, 6",
      ...>   "8, 3",
      ...>   "3, 4",
      ...>   "5, 5",
      ...>   "8, 9",
      ...> ])
      [
        {1, 1},
        {1, 6},
        {8, 3},
        {3, 4},
        {5, 5},
        {8, 9},
      ]

  """
  def parse_coordinates(strings) do
    Enum.map(strings, &coordinate/1) |> Enum.map(fn {:ok, [x, y], "", _, _, _} -> {x, y} end)
  end

  @doc """
  parses input coordinates

  ## Examples

      iex> Day6.coordinate_ranges([
      ...>  {1, 1},
      ...>  {1, 6},
      ...>  {8, 3},
      ...>  {3, 4},
      ...>  {5, 5},
      ...>  {8, 9},
      ...> ])
      {0..9, 0..10}

  """
  def coordinate_ranges([{x1, y1}, {x2, y2} | rest]) do
    [xmin, xmax] = Enum.sort([x1, x2])
    [ymin, ymax] = Enum.sort([y1, y2])
    coordinate_ranges(rest, xmin, xmax, ymin, ymax)
  end

  defp coordinate_ranges([{x, y} | rest], xmin, xmax, ymin, ymax) do
    coordinate_ranges(rest, min(xmin, x), max(xmax, x), min(ymin, y), max(ymax, y))
  end

  defp coordinate_ranges([], xmin, xmax, ymin, ymax) do
    {(xmin - 1)..(xmax + 1), (ymin - 1)..(ymax + 1)}
  end

  @doc """
  Calculate the Manhattan Distance between two coordinates

  ## Examples

      iex> Day6.cab_dist({1, 1}, {2, 2})
      2

      iex> Day6.cab_dist({3, 1}, {0, 2})
      4

      iex> Day6.cab_dist({7, 28}, {9, 14})
      16

      iex> Day6.cab_dist({-3, 1}, {2, -2})
      8

  """
  def cab_dist({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  @doc """

  ## Examples

      iex> coordinates = [
      ...>  {1, 1},
      ...>  {1, 6},
      ...>  {8, 3},
      ...>  {3, 4},
      ...>  {5, 5},
      ...>  {8, 9},
      ...> ]
      iex> Day6.closest_coordinates(coordinates, Day6.coordinate_ranges(coordinates))
      [
        {{0, 0}, {1, 1}, 2},
        {{0, 1}, {1, 1}, 1},
        {{0, 2}, {1, 1}, 2},
        {{0, 3}, {1, 1}, 3},
        {{0, 5}, {1, 6}, 2},
        {{0, 6}, {1, 6}, 1},
        {{0, 7}, {1, 6}, 2},
        {{0, 8}, {1, 6}, 3},
        {{0, 9}, {1, 6}, 4},
        {{0, 10}, {1, 6}, 5},
        {{1, 0}, {1, 1}, 1},
        {{1, 1}, {1, 1}, 0},
        {{1, 2}, {1, 1}, 1},
        {{1, 3}, {1, 1}, 2},
        {{1, 5}, {1, 6}, 1},
        {{1, 6}, {1, 6}, 0},
        {{1, 7}, {1, 6}, 1},
        {{1, 8}, {1, 6}, 2},
        {{1, 9}, {1, 6}, 3},
        {{1, 10}, {1, 6}, 4},
        {{2, 0}, {1, 1}, 2},
        {{2, 1}, {1, 1}, 1},
        {{2, 2}, {1, 1}, 2},
        {{2, 3}, {3, 4}, 2},
        {{2, 4}, {3, 4}, 1},
        {{2, 6}, {1, 6}, 1},
        {{2, 7}, {1, 6}, 2},
        {{2, 8}, {1, 6}, 3},
        {{2, 9}, {1, 6}, 4},
        {{2, 10}, {1, 6}, 5},
        {{3, 0}, {1, 1}, 3},
        {{3, 1}, {1, 1}, 2},
        {{3, 2}, {3, 4}, 2},
        {{3, 3}, {3, 4}, 1},
        {{3, 4}, {3, 4}, 0},
        {{3, 5}, {3, 4}, 1},
        {{4, 0}, {1, 1}, 4},
        {{4, 1}, {1, 1}, 3},
        {{4, 2}, {3, 4}, 3},
        {{4, 3}, {3, 4}, 2},
        {{4, 4}, {3, 4}, 1},
        {{4, 5}, {5, 5}, 1},
        {{4, 6}, {5, 5}, 2},
        {{4, 7}, {5, 5}, 3},
        {{4, 8}, {5, 5}, 4},
        {{4, 9}, {8, 9}, 4},
        {{4, 10}, {8, 9}, 5},
        {{5, 2}, {5, 5}, 3},
        {{5, 3}, {5, 5}, 2},
        {{5, 4}, {5, 5}, 1},
        {{5, 5}, {5, 5}, 0},
        {{5, 6}, {5, 5}, 1},
        {{5, 7}, {5, 5}, 2},
        {{5, 8}, {5, 5}, 3},
        {{5, 9}, {8, 9}, 3},
        {{5, 10}, {8, 9}, 4},
        {{6, 0}, {8, 3}, 5},
        {{6, 1}, {8, 3}, 4},
        {{6, 2}, {8, 3}, 3},
        {{6, 3}, {8, 3}, 2},
        {{6, 4}, {5, 5}, 2},
        {{6, 5}, {5, 5}, 1},
        {{6, 6}, {5, 5}, 2},
        {{6, 7}, {5, 5}, 3},
        {{6, 8}, {8, 9}, 3},
        {{6, 9}, {8, 9}, 2},
        {{6, 10}, {8, 9}, 3},
        {{7, 0}, {8, 3}, 4},
        {{7, 1}, {8, 3}, 3},
        {{7, 2}, {8, 3}, 2},
        {{7, 3}, {8, 3}, 1},
        {{7, 4}, {8, 3}, 2},
        {{7, 5}, {5, 5}, 2},
        {{7, 6}, {5, 5}, 3},
        {{7, 7}, {8, 9}, 3},
        {{7, 8}, {8, 9}, 2},
        {{7, 9}, {8, 9}, 1},
        {{7, 10}, {8, 9}, 2},
        {{8, 0}, {8, 3}, 3},
        {{8, 1}, {8, 3}, 2},
        {{8, 2}, {8, 3}, 1},
        {{8, 3}, {8, 3}, 0},
        {{8, 4}, {8, 3}, 1},
        {{8, 5}, {8, 3}, 2},
        {{8, 7}, {8, 9}, 2},
        {{8, 8}, {8, 9}, 1},
        {{8, 9}, {8, 9}, 0},
        {{8, 10}, {8, 9}, 1},
        {{9, 0}, {8, 3}, 4},
        {{9, 1}, {8, 3}, 3},
        {{9, 2}, {8, 3}, 2},
        {{9, 3}, {8, 3}, 1},
        {{9, 4}, {8, 3}, 2},
        {{9, 5}, {8, 3}, 3},
        {{9, 7}, {8, 9}, 3},
        {{9, 8}, {8, 9}, 2},
        {{9, 9}, {8, 9}, 1},
        {{9, 10}, {8, 9}, 2},
      ]

  """
  def closest_coordinates(coordinates, ranges) do
    {xrange, yrange} = ranges

    for(x <- xrange, y <- yrange, do: {x, y})
    |> Enum.reduce([], fn point, acc ->
      case closest_to_point(point, coordinates) do
        :none ->
          acc

        {closest, distance} ->
          [{point, closest, distance} | acc]
      end
    end)
    |> Enum.reverse()
  end

  @doc """

  ## Examples

      iex> Day6.closest_to_point({1, 1}, [
      ...>  {1, 1},
      ...>  {1, 6},
      ...>  {8, 3},
      ...>  {3, 4},
      ...>  {5, 5},
      ...>  {8, 9},
      ...> ])
      {{1, 1}, 0}

      iex> Day6.closest_to_point({1, 5}, [
      ...>  {1, 1},
      ...>  {1, 6},
      ...>  {8, 3},
      ...>  {3, 4},
      ...>  {5, 5},
      ...>  {8, 9},
      ...> ])
      {{1, 6}, 1}

      iex> Day6.closest_to_point({8, 2}, [
      ...>  {1, 1},
      ...>  {1, 6},
      ...>  {8, 3},
      ...>  {3, 4},
      ...>  {5, 5},
      ...>  {8, 9},
      ...> ])
      {{8, 3}, 1}

      iex> Day6.closest_to_point({5, 1}, [
      ...>  {1, 1},
      ...>  {1, 6},
      ...>  {8, 3},
      ...>  {3, 4},
      ...>  {5, 5},
      ...>  {8, 9},
      ...> ])
      :none

  """
  def closest_to_point(point, [next | coordinates]) do
    closest_to_point(point, coordinates, [next], cab_dist(point, next))
  end

  defp closest_to_point(point, [next | coordinates], closest_coordinates, distance) do
    new_distance = cab_dist(point, next)

    case new_distance do
      _ when new_distance < distance ->
        closest_to_point(point, coordinates, [next], new_distance)

      _ when new_distance == distance ->
        closest_to_point(point, coordinates, [next | closest_coordinates], distance)

      _ when new_distance > distance ->
        closest_to_point(point, coordinates, closest_coordinates, distance)
    end
  end

  defp closest_to_point(_point, [], closest_coordinates, distance) do
    case closest_coordinates do
      [closest | []] ->
        {closest, distance}

      _ ->
        :none
    end
  end

  @doc """

  ## Examples

      iex> Day6.coordinate_zone_sizes([
      ...>  {1, 1},
      ...>  {1, 6},
      ...>  {8, 3},
      ...>  {3, 4},
      ...>  {5, 5},
      ...>  {8, 9},
      ...> ])
      %{
        {1, 1} => :infinite,
        {1, 6} => :infinite,
        {8, 3} => :infinite,
        {3, 4} => 9,
        {5, 5} => 17,
        {8, 9} => :infinite,
      }

  """
  def coordinate_zone_sizes(coordinates) do
    {xrange, yrange} = coordinate_ranges(coordinates)
    xmin..xmax = xrange
    ymin..ymax = yrange

    closest_coordinates(coordinates, {xrange, yrange})
    |> Enum.reduce(Map.new(), fn {point, coordinate, _dist}, acc ->
      case point do
        {x, y} when x == xmin or x == xmax or y == ymin or y == ymax ->
          Map.put(acc, coordinate, :infinite)

        _ ->
          Map.update(acc, coordinate, 1, fn
            :infinite ->
              :infinite

            x ->
              x + 1
          end)
      end
    end)
  end

  @doc """

  ## Examples

      iex> Day6.point_total_distance_from_all_coordinates({4, 3}, [
      ...>  {1, 1},
      ...>  {1, 6},
      ...>  {8, 3},
      ...>  {3, 4},
      ...>  {5, 5},
      ...>  {8, 9},
      ...> ])
      30

  """
  def point_total_distance_from_all_coordinates(point, coordinates) do
    coordinates
    |> Enum.reduce(0, fn coordinate, acc ->
      acc + cab_dist(point, coordinate)
    end)
  end

  @doc """

  ## Examples

      iex> Day6.close_region_size([
      ...>  {1, 1},
      ...>  {1, 6},
      ...>  {8, 3},
      ...>  {3, 4},
      ...>  {5, 5},
      ...>  {8, 9},
      ...> ], 32)
      16

  """
  def close_region_size(coordinates, max_dist) do
    {xrange, yrange} = coordinate_ranges(coordinates)

    good_points = for x <- xrange, y <- yrange do
      {{x, y}, point_total_distance_from_all_coordinates({x, y}, coordinates)}
    end
    |> Enum.filter(fn {_, dist} -> dist < max_dist end)
    |> length()

    # good_bounds = Enum.map(good_points, fn {point, _} -> point end)
    # |> coordinate_ranges()
    #
    # IO.inspect good_bounds
    # {x1..x2, y1..y2} = good_bounds
    # ((x2-x1) * (y2-y1))
  end
end
