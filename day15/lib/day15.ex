defmodule Day15 do
  defmodule Elf do
    defstruct hp: 200
  end

  defmodule Goblin do
    defstruct hp: 200
  end

  defprotocol Unit do
    def hp_remaining(unit)
    def take_hit(unit)
  end

  defimpl Unit, for: Goblin do
    def hp_remaining(unit) do
      unit.hp
    end

    def take_hit(unit) do
      %Goblin{hp: unit.hp - 3}
    end
  end

  defimpl Unit, for: Elf do
    def hp_remaining(unit) do
      unit.hp
    end

    def take_hit(unit) do
      %Elf{hp: unit.hp - 3}
    end
  end

  def enemies?(%l{}, %r{}) do
    l != r
  end

  def parse_input(string) do
    parse_input(string, %{}, 0, 0)
  end

  defp parse_input("", map, _, _) do
    map
  end

  defp parse_input(<<next::binary-1, rest::binary>>, map, x, y) do
    case next do
      "\n" ->
        parse_input(rest, map, 0, y + 1)

      "#" ->
        parse_input(rest, Map.put(map, {x, y}, :wall), x + 1, y)

      "G" ->
        parse_input(rest, Map.put(map, {x, y}, %Goblin{}), x + 1, y)

      "E" ->
        parse_input(rest, Map.put(map, {x, y}, %Elf{}), x + 1, y)

      _ ->
        parse_input(rest, map, x + 1, y)
    end
  end

  def unit_turns(board) do
    Enum.reduce(board, [], fn
      {coord, %Goblin{}}, acc ->
        [coord | acc]

      {coord, %Elf{}}, acc ->
        [coord | acc]

      {_coord, :wall}, acc ->
        acc
    end)
    |> sort_coords_by_reading_order()
  end

  def valid_destinations(turns, board, unit) do
    case Enum.filter(turns, fn u -> enemies?(Map.get(board, u), unit) end) do
      [] -> :no_targets
      targets -> MapSet.new(targets)
    end
  end

  defp sort_coords_by_reading_order(coords) do
    coords
    |> Enum.sort_by(fn {x, y} -> {y, x} end)
  end

  defp sort_lists_by_reading_order(coord_list) do
    coord_list
    |> Enum.sort_by(fn [{x, y} | _] -> {y, x} end)
  end

  def valid_move?(board, coord, unit) do
    case Map.get(board, coord) do
      nil -> true
      :wall -> false
      occupant -> enemies?(occupant, unit)
    end
  end

  def choose_destination(board, valid_destinations, {_x, _y} = coord) do
    unit = Map.get(board, coord)
    choose_destination(board, valid_destinations, [[coord]], MapSet.new([coord]), unit)
  end

  def choose_destination(_board, _valid_destinations, [], _covered, _unit) do
    :no_moves
  end

  def choose_destination(board, valid_destinations, chains, covered, unit) when is_list(chains) do
    {chains, covered} =
      Enum.reduce(chains, {[], covered}, fn [{x, y} | _] = chain, {acc, covered} ->
        next_coords =
          [{x, y - 1}, {x - 1, y}, {x + 1, y}, {x, y + 1}]
          |> Enum.reject(fn {x, y} -> x < 0 or y < 0 end)
          |> Enum.filter(fn coord -> valid_move?(board, coord, unit) end)
          |> Enum.reject(fn coord -> MapSet.member?(covered, coord) end)

        case next_coords do
          [] ->
            {acc, covered}

          next_coords ->
            covered =
              Enum.reduce(next_coords, covered, fn coord, acc -> MapSet.put(acc, coord) end)

            acc = Enum.reduce(next_coords, acc, fn coord, acc -> [[coord | chain] | acc] end)
            {acc, covered}
        end
      end)

    chains = sort_lists_by_reading_order(chains)

    matched_destinations =
      Enum.filter(chains, fn [head | _] -> MapSet.member?(valid_destinations, head) end)

    case matched_destinations do
      [] ->
        choose_destination(board, valid_destinations, chains, covered, unit)

      dests ->
        case dests do
          [dest | []] ->
            Enum.reverse(dest)
            |> Enum.drop(1)

          dests ->
            candidates = sort_lists_by_reading_order(dests)
            dest_coord = List.first(candidates) |> List.first()

            Enum.filter(candidates, fn [coord | _] -> dest_coord == coord end)
            |> Enum.map(&Enum.reverse/1)
            |> Enum.map(&Enum.drop(&1, 1))
            |> sort_lists_by_reading_order()
            |> List.first()
        end
    end
  end

  def attack_target(board, coord, %s{} = unit) when s in [Goblin, Elf] do
    case unit do
      %Elf{} ->
        attack_target(board, coord, fn {_, unit} -> match?(%Goblin{}, unit) end)

      %Goblin{} ->
        attack_target(board, coord, fn {_, unit} -> match?(%Elf{}, unit) end)
    end
  end

  def attack_target(board, {x, y}, unit_filter) when is_function(unit_filter) do
    result =
      [{x, y - 1}, {x - 1, y}, {x + 1, y}, {x, y + 1}]
      |> Enum.reduce([], fn coord, acc ->
        case Map.get(board, coord) do
          nil ->
            acc

          unit ->
            [{coord, unit} | acc]
        end
      end)
      |> Enum.filter(unit_filter)
      |> Enum.sort_by(fn {{x, y}, unit} ->
        {Unit.hp_remaining(unit), y, x}
      end)
      |> List.first()

    case result do
      {coord, unit} ->
        case Unit.hp_remaining(unit) do
          x when x > 3 ->
            %{board | coord => Unit.take_hit(unit)}

          _ ->
            Map.delete(board, coord)
        end

      nil ->
        :none_in_range
    end
  end

  def run_unit_turn(board, units, coord) do
    case Map.pop(board, coord) do
      {nil, _} ->
        {:ok, board}

      {unit, new_board} ->
        case attack_target(board, coord, unit) do
          :none_in_range ->
            case valid_destinations(units, board, unit) do
              :no_targets ->
                {:no_targets, board}

              :no_moves ->
                {:ok, board}

              dests ->
                case choose_destination(board, dests, coord) do
                  [move | _] ->
                    new_board = Map.put(new_board, move, unit)

                    case attack_target(new_board, move, unit) do
                      :none_in_range -> {:ok, new_board}
                      new_board -> {:ok, new_board}
                    end

                  :no_moves ->
                    {:ok, board}
                end
            end

          new_board ->
            {:ok, new_board}
        end
    end
  end

  def run_rounds(board, 0) do
    {:ok, board}
  end

  def run_rounds(board, count) do
    case run_round(board) do
      {:ok, new_board} -> run_rounds(new_board, count - 1)
      {:no_targets, new_board} -> {:no_targets, new_board, count}
    end
  end

  def run_round(board) do
    units = unit_turns(board)

    Enum.reduce_while(units, {:ok, board}, fn coord, {_, board} ->
      units = unit_turns(board)

      case run_unit_turn(board, units, coord) do
        {:ok, _} = result -> {:cont, result}
        {:no_targets, _} = result -> {:halt, result}
      end
    end)
  end

  def fight!(board) do
    {board, count} = fight!(board, 0)

    score = score_fight(board, count)

    {board, count, score}
  end

  defp fight!(board, count) do
    case run_round(board) do
      {:ok, board} -> fight!(board, count + 1)
      {:no_targets, board} -> {board, count}
    end
  end

  def score_fight(board, count) do
    hp =
      Map.values(board)
      |> Enum.reduce(0, fn
        :wall, acc ->
          acc

        unit, acc ->
          Unit.hp_remaining(unit) + acc
      end)

    hp * count
  end

  def print_board(board) do
    [{xinit, yinit} | coords] = Map.keys(board)

    {xmin, xmax, ymin, ymax} =
      Enum.reduce(coords, {xinit, xinit, yinit, yinit}, fn {x, y}, {xmin, xmax, ymin, ymax} ->
        {min(x, xmin), max(x, xmax), min(y, ymin), max(y, ymax)}
      end)

    Enum.map(ymax..ymin, fn y ->
      Enum.reduce(xmax..xmin, to_charlist("\n"), fn x, acc ->
        case Map.get(board, {x, y}) do
          :wall -> [?# | acc]
          %Goblin{} -> [?G | acc]
          %Elf{} -> [?E | acc]
          nil -> [?. | acc]
        end
      end)
      |> to_string()
    end)
    |> Enum.reduce(&<>/2)
  end
end
