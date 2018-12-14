defmodule Day13 do
  @type coord :: {non_neg_integer, non_neg_integer}
  @type car_symbol :: char
  @type car :: {car_symbol, atom}
  @type cars :: %{coord => car}
  @type track_section :: char
  @type tracks :: %{coord => track_section}

  def parse_input(input) do
    {cars, tracks, _} =
      String.to_charlist(input)
      |> Enum.reduce({%{}, %{}, {0, 0}}, fn char, {cars, tracks, {row, col} = coord} ->
        case char do
          x when x in [?>, ?<] ->
            {
              Map.put(cars, coord, {x, :left}),
              Map.put(tracks, coord, ?-),
              {row, col + 1}
            }

          x when x in [?^, ?v] ->
            {
              Map.put(cars, coord, {x, :left}),
              Map.put(tracks, coord, ?|),
              {row, col + 1}
            }

          x when x in [?-, ?+, ?-, ?\\, ?/, ?|] ->
            {
              cars,
              Map.put(tracks, coord, x),
              {row, col + 1}
            }

          ?\n ->
            {cars, tracks, {row + 1, 0}}

          _ ->
            {cars, tracks, {row, col + 1}}
        end
      end)

    {cars, tracks}
  end

  @spec find_collision(cars, tracks) :: coord
  def find_collision(cars, tracks) do
    case next_tick(cars, tracks) do
      {:ok, new_cars} ->
        find_collision(new_cars, tracks)

      {:crash, {y, x}} ->
        {x, y}
    end
  end

  @spec next_tick(cars, tracks) :: {:ok, cars} | {:crash, coord}
  def next_tick(cars, tracks) do
    cars_to_run =
      Map.to_list(cars)
      |> Enum.sort_by(fn {coord, _} -> coord end)

    next_tick(cars, tracks, cars_to_run)
  end

  defp next_tick(cars, _tracks, []) do
    {:ok, cars}
  end

  defp next_tick(cars, tracks, [{coord, car} | cars_to_run]) do
    cars = Map.delete(cars, coord)
    {new_coord, new_car} = advance_car(coord, car, tracks)

    if Map.has_key?(cars, new_coord) do
      {:crash, new_coord}
    else
      cars = Map.put(cars, new_coord, new_car)
      next_tick(cars, tracks, cars_to_run)
    end
  end

  @spec advance_car(coord, car, tracks) :: {coord, car}
  def advance_car({row, col}, {direction, next_turn} = car, tracks) do
    new_coord =
      case direction do
        ?^ ->
          {row - 1, col}

        ?v ->
          {row + 1, col}

        ?< ->
          {row, col - 1}

        ?> ->
          {row, col + 1}
      end

    new_car =
      case {tracks[new_coord], direction} do
        {?\\, ?<} ->
          {?^, next_turn}

        {?\\, ?>} ->
          {?v, next_turn}

        {?\\, ?v} ->
          {?>, next_turn}

        {?\\, ?^} ->
          {?<, next_turn}

        {?/, ?<} ->
          {?v, next_turn}

        {?/, ?>} ->
          {?^, next_turn}

        {?/, ?v} ->
          {?<, next_turn}

        {?/, ?^} ->
          {?>, next_turn}

        {?+, _} ->
          make_turn(car)

        _ ->
          car
      end

    {new_coord, new_car}
  end

  @spec make_turn(car) :: car
  defp make_turn({direction, next_turn}) do
    case next_turn do
      :left ->
        case direction do
          ?^ ->
            {?<, :straight}

          ?< ->
            {?v, :straight}

          ?v ->
            {?>, :straight}

          ?> ->
            {?^, :straight}
        end

      :straight ->
        {direction, :right}

      :right ->
        case direction do
          ?^ ->
            {?>, :left}

          ?> ->
            {?v, :left}

          ?v ->
            {?<, :left}

          ?< ->
            {?^, :left}
        end
    end
  end
end
