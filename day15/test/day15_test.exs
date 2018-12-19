defmodule Day15Test do
  use ExUnit.Case
  doctest Day15
  import Day15

  describe "parse_input" do
    test "initial parse" do
      input = ~S"""
      #######
      #.G...#
      #...EG#
      #.#.#G#
      #..G#E#
      #.....#
      #######
      """

      assert parse_input(input) == %{
               {0, 0} => :wall,
               {1, 0} => :wall,
               {2, 0} => :wall,
               {3, 0} => :wall,
               {4, 0} => :wall,
               {5, 0} => :wall,
               {6, 0} => :wall,
               {0, 1} => :wall,
               {2, 1} => %Day15.Goblin{hp: 200},
               {6, 1} => :wall,
               {0, 2} => :wall,
               {4, 2} => %Day15.Elf{hp: 200},
               {5, 2} => %Day15.Goblin{hp: 200},
               {6, 2} => :wall,
               {0, 3} => :wall,
               {2, 3} => :wall,
               {4, 3} => :wall,
               {5, 3} => %Day15.Goblin{hp: 200},
               {6, 3} => :wall,
               {0, 4} => :wall,
               {3, 4} => %Day15.Goblin{hp: 200},
               {4, 4} => :wall,
               {5, 4} => %Day15.Elf{hp: 200},
               {6, 4} => :wall,
               {0, 5} => :wall,
               {6, 5} => :wall,
               {0, 6} => :wall,
               {1, 6} => :wall,
               {2, 6} => :wall,
               {3, 6} => :wall,
               {4, 6} => :wall,
               {5, 6} => :wall,
               {6, 6} => :wall
             }
    end
  end

  def setup_parsed_input(_context) do
    raw_input = ~S"""
    #######
    #.G...#
    #...EG#
    #.#.#G#
    #..G#E#
    #.....#
    #######
    """

    [input: parse_input(raw_input)]
  end

  describe "unit_turns" do
    setup :setup_parsed_input

    test "initial input", %{input: input} do
      assert unit_turns(input) == [
               {2, 1},
               {4, 2},
               {5, 2},
               {5, 3},
               {3, 4},
               {5, 4}
             ]
    end
  end

  def setup_unit_turns(%{input: input}) do
    [turns: unit_turns(input)]
  end

  describe "valid_destinations" do
    setup :setup_parsed_input
    setup :setup_unit_turns

    test "on initial input with Elf", %{turns: turns, input: input} do
      assert valid_destinations(turns, input, %Day15.Elf{}) ==
               MapSet.new([
                 {2, 1},
                 {5, 2},
                 {5, 3},
                 {3, 4}
               ])
    end

    test "on initial input with Goblin", %{turns: turns, input: input} do
      assert valid_destinations(turns, input, %Day15.Goblin{}) ==
               MapSet.new([
                 {4, 2},
                 {5, 4}
               ])
    end

    test "when there are no valid Goblin targets left" do
      board =
        ~S"""
        #######
        #E....#
        #...#E#
        #...#.#
        #######
        """
        |> parse_input()

      dests =
        unit_turns(board)
        |> valid_destinations(board, %Day15.Elf{})

      assert dests == :no_targets
    end

    test "when there are no valid Elf targets left" do
      board =
        ~S"""
        #######
        #G....#
        #...#G#
        #...#.#
        #######
        """
        |> parse_input()

      dests =
        unit_turns(board)
        |> valid_destinations(board, %Day15.Goblin{})

      assert dests == :no_targets
    end
  end

  describe "choose_destination" do
    test "with one closest choice" do
      board =
        ~S"""
        #######
        #E..G.#
        #...#.#
        #...#G#
        #######
        """
        |> parse_input()

      dests =
        unit_turns(board)
        |> valid_destinations(board, %Day15.Elf{})

      assert dests == MapSet.new([{4, 1}, {5, 3}])

      assert choose_destination(board, dests, {1, 1}) == [{2, 1}, {3, 1}, {4, 1}]
    end

    test "with multiple choices" do
      board =
        ~S"""
        #######
        #E..G.#
        #...#.#
        #.G.#G#
        #######
        """
        |> parse_input()

      dests =
        unit_turns(board)
        |> valid_destinations(board, %Day15.Elf{})

      assert dests == MapSet.new([{4, 1}, {2, 3}, {5, 3}])

      assert choose_destination(board, dests, {1, 1}) == [{2, 1}, {3, 1}, {4, 1}]
    end

    test "goes around a corner" do
      board =
        ~S"""
        #######
        #E.#G.#
        #..##.#
        #.....#
        #######
        """
        |> parse_input()

      dests =
        unit_turns(board)
        |> valid_destinations(board, %Day15.Elf{})

      assert dests == MapSet.new([{4, 1}])

      assert choose_destination(board, dests, {1, 1}) == [
               {2, 1},
               {2, 2},
               {2, 3},
               {3, 3},
               {4, 3},
               {5, 3},
               {5, 2},
               {5, 1},
               {4, 1}
             ]
    end

    test "picks the shortest path" do
      board =
        ~S"""
        #######
        #.....#
        #..##.#
        #..#G.#
        #E.##.#
        #.....#
        #.....#
        #######
        """
        |> parse_input()

      dests =
        unit_turns(board)
        |> valid_destinations(board, %Day15.Elf{})

      assert dests == MapSet.new([{4, 3}])

      assert choose_destination(board, dests, {1, 4}) == [
               {2, 4},
               {2, 5},
               {3, 5},
               {4, 5},
               {5, 5},
               {5, 4},
               {5, 3},
               {4, 3}
             ]
    end

    test "blocked" do
      board =
        ~S"""
        #######
        #.....#
        #..##.#
        #..#GE#
        #E.##.#
        #.....#
        #.....#
        #######
        """
        |> parse_input()

      dests =
        unit_turns(board)
        |> valid_destinations(board, %Day15.Elf{})

      assert dests == MapSet.new([{4, 3}])

      assert choose_destination(board, dests, {1, 4}) == :no_moves
    end

    test "cant get there" do
      board =
        ~S"""
        #######
        #.....#
        #..##E#
        #..#G.#
        #E.##E#
        #.....#
        #.....#
        #######
        """
        |> parse_input()

      dests =
        unit_turns(board)
        |> valid_destinations(board, %Day15.Elf{})

      assert dests == MapSet.new([{4, 3}])

      assert choose_destination(board, dests, {1, 4}) == :no_moves
    end
  end

  describe "attack_target" do
    test "picks the target in hp order and removes 3 hp" do
      board =
        Map.new([
          {{3, 2}, %Day15.Goblin{hp: 200}},
          {{3, 3}, %Day15.Elf{hp: 200}},
          {{3, 4}, %Day15.Goblin{hp: 150}}
        ])

      assert attack_target(board, {3, 3}, Map.get(board, {3, 3})) ==
               Map.new([
                 {{3, 2}, %Day15.Goblin{hp: 200}},
                 {{3, 3}, %Day15.Elf{hp: 200}},
                 {{3, 4}, %Day15.Goblin{hp: 147}}
               ])
    end

    test "when hp is the same, picks the target that is first in reading order" do
      board =
        Map.new([
          {{3, 2}, %Day15.Goblin{hp: 200}},
          {{3, 3}, %Day15.Elf{hp: 200}},
          {{3, 4}, %Day15.Goblin{hp: 200}}
        ])

      assert attack_target(board, {3, 3}, Map.get(board, {3, 3})) ==
               Map.new([
                 {{3, 2}, %Day15.Goblin{hp: 197}},
                 {{3, 3}, %Day15.Elf{hp: 200}},
                 {{3, 4}, %Day15.Goblin{hp: 200}}
               ])
    end

    test "when hp drops below 1, remove the target from the board" do
      board1 =
        Map.new([
          {{3, 2}, %Day15.Goblin{hp: 3}},
          {{3, 3}, %Day15.Elf{hp: 200}}
        ])

      assert attack_target(board1, {3, 3}, Map.get(board1, {3, 3})) ==
               Map.new([
                 {{3, 3}, %Day15.Elf{hp: 200}}
               ])

      board2 =
        Map.new([
          {{3, 2}, %Day15.Goblin{hp: 2}},
          {{3, 3}, %Day15.Elf{hp: 200}}
        ])

      assert attack_target(board2, {3, 3}, Map.get(board2, {3, 3})) ==
               Map.new([
                 {{3, 3}, %Day15.Elf{hp: 200}}
               ])

      board3 =
        Map.new([
          {{3, 2}, %Day15.Goblin{hp: 1}},
          {{3, 3}, %Day15.Elf{hp: 200}}
        ])

      assert attack_target(board3, {3, 3}, Map.get(board3, {3, 3})) ==
               Map.new([
                 {{3, 3}, %Day15.Elf{hp: 200}}
               ])
    end

    test "when there are no targets, it does nothing" do
      board =
        Map.new([
          {{3, 1}, %Day15.Goblin{hp: 200}},
          {{3, 3}, %Day15.Elf{hp: 200}}
        ])

      assert attack_target(board, {3, 1}, Map.get(board, {3, 1})) == :none_in_range
      assert attack_target(board, {3, 3}, Map.get(board, {3, 3})) == :none_in_range
    end

    test "only attacks enemies, not friends" do
      board1 =
        Map.new([
          {{3, 2}, %Day15.Elf{hp: 200}},
          {{3, 3}, %Day15.Elf{hp: 200}}
        ])

      assert attack_target(board1, {3, 3}, Map.get(board1, {3, 3})) == :none_in_range

      board2 =
        Map.new([
          {{3, 2}, %Day15.Goblin{hp: 200}},
          {{3, 3}, %Day15.Goblin{hp: 200}}
        ])

      assert attack_target(board2, {3, 3}, Map.get(board2, {3, 3})) == :none_in_range
    end
  end

  describe "run_unit_turn" do
    test "it moves toward an enemy unit" do
      board =
        Map.new([
          {{3, 1}, %Day15.Goblin{hp: 200}},
          {{3, 4}, %Day15.Elf{hp: 200}}
        ])

      assert run_unit_turn(board, [{3, 4}], {3, 1}) ==
               {:ok,
                Map.new([
                  {{3, 2}, %Day15.Goblin{hp: 200}},
                  {{3, 4}, %Day15.Elf{hp: 200}}
                ])}

      assert run_unit_turn(board, [{3, 1}], {3, 4}) ==
               {:ok,
                Map.new([
                  {{3, 1}, %Day15.Goblin{hp: 200}},
                  {{3, 3}, %Day15.Elf{hp: 200}}
                ])}
    end

    test "it does nothing if the coord doesn't point to a unit" do
      board =
        Map.new([
          {{3, 1}, %Day15.Goblin{hp: 200}},
          {{3, 4}, %Day15.Elf{hp: 200}}
        ])

      assert run_unit_turn(board, [{3, 1}, {3, 4}], {3, 2}) ==
               {:ok,
                Map.new([
                  {{3, 1}, %Day15.Goblin{hp: 200}},
                  {{3, 4}, %Day15.Elf{hp: 200}}
                ])}
    end

    test "it attacks without moving if it can" do
      board =
        Map.new([
          {{3, 1}, %Day15.Goblin{hp: 200}},
          {{3, 4}, %Day15.Elf{hp: 200}},
          {{4, 4}, %Day15.Goblin{hp: 200}}
        ])

      assert run_unit_turn(board, [{3, 1}, {4, 4}], {3, 4}) ==
               {:ok,
                Map.new([
                  {{3, 1}, %Day15.Goblin{hp: 200}},
                  {{3, 4}, %Day15.Elf{hp: 200}},
                  {{4, 4}, %Day15.Goblin{hp: 197}}
                ])}
    end

    test "it will move and then attack if needed" do
      board =
        Map.new([
          {{3, 1}, %Day15.Goblin{hp: 200}},
          {{3, 4}, %Day15.Elf{hp: 200}},
          {{5, 4}, %Day15.Goblin{hp: 200}}
        ])

      assert run_unit_turn(board, [{3, 1}, {5, 4}], {3, 4}) ==
               {:ok,
                Map.new([
                  {{3, 1}, %Day15.Goblin{hp: 200}},
                  {{4, 4}, %Day15.Elf{hp: 200}},
                  {{5, 4}, %Day15.Goblin{hp: 197}}
                ])}
    end
  end

  describe "run_round" do
    setup do
      raw_input = ~S"""
      #######
      #.G...#
      #...EG#
      #.#.#G#
      #..G#E#
      #.....#
      #######
      """

      [input: parse_input(raw_input)]
    end

    test "start state", %{input: board} do
      assert board == %{
               {0, 0} => :wall,
               {1, 0} => :wall,
               {2, 0} => :wall,
               {3, 0} => :wall,
               {4, 0} => :wall,
               {5, 0} => :wall,
               {6, 0} => :wall,
               {0, 1} => :wall,
               {2, 1} => %Day15.Goblin{hp: 200},
               {6, 1} => :wall,
               {0, 2} => :wall,
               {4, 2} => %Day15.Elf{hp: 200},
               {5, 2} => %Day15.Goblin{hp: 200},
               {6, 2} => :wall,
               {0, 3} => :wall,
               {2, 3} => :wall,
               {4, 3} => :wall,
               {5, 3} => %Day15.Goblin{hp: 200},
               {6, 3} => :wall,
               {0, 4} => :wall,
               {3, 4} => %Day15.Goblin{hp: 200},
               {4, 4} => :wall,
               {5, 4} => %Day15.Elf{hp: 200},
               {6, 4} => :wall,
               {0, 5} => :wall,
               {6, 5} => :wall,
               {0, 6} => :wall,
               {1, 6} => :wall,
               {2, 6} => :wall,
               {3, 6} => :wall,
               {4, 6} => :wall,
               {5, 6} => :wall,
               {6, 6} => :wall
             }
    end

    test "after first round", %{input: board} do
      {:ok, new_board} = run_round(board)

      assert new_board == %{
               {3, 1} => %Day15.Goblin{hp: 200},
               {4, 2} => %Day15.Elf{hp: 197},
               {5, 2} => %Day15.Goblin{hp: 197},
               {3, 3} => %Day15.Goblin{hp: 200},
               {5, 3} => %Day15.Goblin{hp: 197},
               {5, 4} => %Day15.Elf{hp: 197},
               {0, 0} => :wall,
               {1, 0} => :wall,
               {2, 0} => :wall,
               {3, 0} => :wall,
               {4, 0} => :wall,
               {5, 0} => :wall,
               {6, 0} => :wall,
               {0, 1} => :wall,
               {6, 1} => :wall,
               {0, 2} => :wall,
               {6, 2} => :wall,
               {0, 3} => :wall,
               {2, 3} => :wall,
               {4, 3} => :wall,
               {6, 3} => :wall,
               {0, 4} => :wall,
               {4, 4} => :wall,
               {6, 4} => :wall,
               {0, 5} => :wall,
               {6, 5} => :wall,
               {0, 6} => :wall,
               {1, 6} => :wall,
               {2, 6} => :wall,
               {3, 6} => :wall,
               {4, 6} => :wall,
               {5, 6} => :wall,
               {6, 6} => :wall
             }
    end

    test "after second round", %{input: board} do
      after_round_1 = %{
        {3, 1} => %Day15.Goblin{hp: 200},
        {4, 2} => %Day15.Elf{hp: 197},
        {5, 2} => %Day15.Goblin{hp: 197},
        {3, 3} => %Day15.Goblin{hp: 200},
        {5, 3} => %Day15.Goblin{hp: 197},
        {5, 4} => %Day15.Elf{hp: 197},
        {0, 0} => :wall,
        {1, 0} => :wall,
        {2, 0} => :wall,
        {3, 0} => :wall,
        {4, 0} => :wall,
        {5, 0} => :wall,
        {6, 0} => :wall,
        {0, 1} => :wall,
        {6, 1} => :wall,
        {0, 2} => :wall,
        {6, 2} => :wall,
        {0, 3} => :wall,
        {2, 3} => :wall,
        {4, 3} => :wall,
        {6, 3} => :wall,
        {0, 4} => :wall,
        {4, 4} => :wall,
        {6, 4} => :wall,
        {0, 5} => :wall,
        {6, 5} => :wall,
        {0, 6} => :wall,
        {1, 6} => :wall,
        {2, 6} => :wall,
        {3, 6} => :wall,
        {4, 6} => :wall,
        {5, 6} => :wall,
        {6, 6} => :wall
      }

      assert run_round(board) == {:ok, after_round_1}

      {:ok, after_round_2} = run_round(after_round_1)

      assert after_round_2 == %{
               {4, 1} => %Day15.Goblin{hp: 200},
               {3, 2} => %Day15.Goblin{hp: 200},
               {4, 2} => %Day15.Elf{hp: 188},
               {5, 2} => %Day15.Goblin{hp: 194},
               {5, 3} => %Day15.Goblin{hp: 194},
               {5, 4} => %Day15.Elf{hp: 194},
               {0, 0} => :wall,
               {1, 0} => :wall,
               {2, 0} => :wall,
               {3, 0} => :wall,
               {4, 0} => :wall,
               {5, 0} => :wall,
               {6, 0} => :wall,
               {0, 1} => :wall,
               {6, 1} => :wall,
               {0, 2} => :wall,
               {6, 2} => :wall,
               {0, 3} => :wall,
               {2, 3} => :wall,
               {4, 3} => :wall,
               {6, 3} => :wall,
               {0, 4} => :wall,
               {4, 4} => :wall,
               {6, 4} => :wall,
               {0, 5} => :wall,
               {6, 5} => :wall,
               {0, 6} => :wall,
               {1, 6} => :wall,
               {2, 6} => :wall,
               {3, 6} => :wall,
               {4, 6} => :wall,
               {5, 6} => :wall,
               {6, 6} => :wall
             }
    end

    test "after round 23", %{input: board} do
      {:ok, after_round_23} = run_rounds(board, 23)

      assert after_round_23 == %{
               {4, 1} => %Day15.Goblin{hp: 200},
               {3, 2} => %Day15.Goblin{hp: 200},
               {5, 2} => %Day15.Goblin{hp: 131},
               {5, 3} => %Day15.Goblin{hp: 131},
               {5, 4} => %Day15.Elf{hp: 131},
               {0, 0} => :wall,
               {1, 0} => :wall,
               {2, 0} => :wall,
               {3, 0} => :wall,
               {4, 0} => :wall,
               {5, 0} => :wall,
               {6, 0} => :wall,
               {0, 1} => :wall,
               {6, 1} => :wall,
               {0, 2} => :wall,
               {6, 2} => :wall,
               {0, 3} => :wall,
               {2, 3} => :wall,
               {4, 3} => :wall,
               {6, 3} => :wall,
               {0, 4} => :wall,
               {4, 4} => :wall,
               {6, 4} => :wall,
               {0, 5} => :wall,
               {6, 5} => :wall,
               {0, 6} => :wall,
               {1, 6} => :wall,
               {2, 6} => :wall,
               {3, 6} => :wall,
               {4, 6} => :wall,
               {5, 6} => :wall,
               {6, 6} => :wall
             }
    end

    test "after round 24", %{input: board} do
      {:ok, after_round_24} = run_rounds(board, 24)

      assert after_round_24 == %{
               {3, 1} => %Day15.Goblin{hp: 200},
               {3, 3} => %Day15.Goblin{hp: 200},
               {4, 2} => %Day15.Goblin{hp: 131},
               {5, 3} => %Day15.Goblin{hp: 128},
               {5, 4} => %Day15.Elf{hp: 128},
               {0, 0} => :wall,
               {1, 0} => :wall,
               {2, 0} => :wall,
               {3, 0} => :wall,
               {4, 0} => :wall,
               {5, 0} => :wall,
               {6, 0} => :wall,
               {0, 1} => :wall,
               {6, 1} => :wall,
               {0, 2} => :wall,
               {6, 2} => :wall,
               {0, 3} => :wall,
               {2, 3} => :wall,
               {4, 3} => :wall,
               {6, 3} => :wall,
               {0, 4} => :wall,
               {4, 4} => :wall,
               {6, 4} => :wall,
               {0, 5} => :wall,
               {6, 5} => :wall,
               {0, 6} => :wall,
               {1, 6} => :wall,
               {2, 6} => :wall,
               {3, 6} => :wall,
               {4, 6} => :wall,
               {5, 6} => :wall,
               {6, 6} => :wall
             }
    end

    test "after round 25", %{input: board} do
      {:ok, after_round_25} = run_rounds(board, 25)

      assert after_round_25 == %{
               {2, 1} => %Day15.Goblin{hp: 200},
               {3, 2} => %Day15.Goblin{hp: 131},
               {5, 3} => %Day15.Goblin{hp: 125},
               {3, 4} => %Day15.Goblin{hp: 200},
               {5, 4} => %Day15.Elf{hp: 125},
               {0, 0} => :wall,
               {1, 0} => :wall,
               {2, 0} => :wall,
               {3, 0} => :wall,
               {4, 0} => :wall,
               {5, 0} => :wall,
               {6, 0} => :wall,
               {0, 1} => :wall,
               {6, 1} => :wall,
               {0, 2} => :wall,
               {6, 2} => :wall,
               {0, 3} => :wall,
               {2, 3} => :wall,
               {4, 3} => :wall,
               {6, 3} => :wall,
               {0, 4} => :wall,
               {4, 4} => :wall,
               {6, 4} => :wall,
               {0, 5} => :wall,
               {6, 5} => :wall,
               {0, 6} => :wall,
               {1, 6} => :wall,
               {2, 6} => :wall,
               {3, 6} => :wall,
               {4, 6} => :wall,
               {5, 6} => :wall,
               {6, 6} => :wall
             }
    end

    test "after round 26", %{input: board} do
      {:ok, after_round_26} = run_rounds(board, 26)

      assert after_round_26 == %{
               {1, 1} => %Day15.Goblin{hp: 200},
               {2, 2} => %Day15.Goblin{hp: 131},
               {5, 3} => %Day15.Goblin{hp: 122},
               {5, 4} => %Day15.Elf{hp: 122},
               {3, 5} => %Day15.Goblin{hp: 200},
               {0, 0} => :wall,
               {1, 0} => :wall,
               {2, 0} => :wall,
               {3, 0} => :wall,
               {4, 0} => :wall,
               {5, 0} => :wall,
               {6, 0} => :wall,
               {0, 1} => :wall,
               {6, 1} => :wall,
               {0, 2} => :wall,
               {6, 2} => :wall,
               {0, 3} => :wall,
               {2, 3} => :wall,
               {4, 3} => :wall,
               {6, 3} => :wall,
               {0, 4} => :wall,
               {4, 4} => :wall,
               {6, 4} => :wall,
               {0, 5} => :wall,
               {6, 5} => :wall,
               {0, 6} => :wall,
               {1, 6} => :wall,
               {2, 6} => :wall,
               {3, 6} => :wall,
               {4, 6} => :wall,
               {5, 6} => :wall,
               {6, 6} => :wall
             }
    end

    test "after round 27", %{input: board} do
      {:ok, after_round_27} = run_rounds(board, 27)

      assert after_round_27 == %{
               {1, 1} => %Day15.Goblin{hp: 200},
               {2, 2} => %Day15.Goblin{hp: 131},
               {5, 3} => %Day15.Goblin{hp: 119},
               {5, 4} => %Day15.Elf{hp: 119},
               {4, 5} => %Day15.Goblin{hp: 200},
               {0, 0} => :wall,
               {1, 0} => :wall,
               {2, 0} => :wall,
               {3, 0} => :wall,
               {4, 0} => :wall,
               {5, 0} => :wall,
               {6, 0} => :wall,
               {0, 1} => :wall,
               {6, 1} => :wall,
               {0, 2} => :wall,
               {6, 2} => :wall,
               {0, 3} => :wall,
               {2, 3} => :wall,
               {4, 3} => :wall,
               {6, 3} => :wall,
               {0, 4} => :wall,
               {4, 4} => :wall,
               {6, 4} => :wall,
               {0, 5} => :wall,
               {6, 5} => :wall,
               {0, 6} => :wall,
               {1, 6} => :wall,
               {2, 6} => :wall,
               {3, 6} => :wall,
               {4, 6} => :wall,
               {5, 6} => :wall,
               {6, 6} => :wall
             }
    end

    test "after round 28", %{input: board} do
      {:ok, after_round_28} = run_rounds(board, 28)

      assert after_round_28 == %{
               {1, 1} => %Day15.Goblin{hp: 200},
               {2, 2} => %Day15.Goblin{hp: 131},
               {5, 3} => %Day15.Goblin{hp: 116},
               {5, 4} => %Day15.Elf{hp: 113},
               {5, 5} => %Day15.Goblin{hp: 200},
               {0, 0} => :wall,
               {1, 0} => :wall,
               {2, 0} => :wall,
               {3, 0} => :wall,
               {4, 0} => :wall,
               {5, 0} => :wall,
               {6, 0} => :wall,
               {0, 1} => :wall,
               {6, 1} => :wall,
               {0, 2} => :wall,
               {6, 2} => :wall,
               {0, 3} => :wall,
               {2, 3} => :wall,
               {4, 3} => :wall,
               {6, 3} => :wall,
               {0, 4} => :wall,
               {4, 4} => :wall,
               {6, 4} => :wall,
               {0, 5} => :wall,
               {6, 5} => :wall,
               {0, 6} => :wall,
               {1, 6} => :wall,
               {2, 6} => :wall,
               {3, 6} => :wall,
               {4, 6} => :wall,
               {5, 6} => :wall,
               {6, 6} => :wall
             }
    end
  end

  describe "fight!" do
    test "run a full battle" do
      raw_input = ~S"""
      #######
      #.G...#
      #...EG#
      #.#.#G#
      #..G#E#
      #.....#
      #######
      """

      board = parse_input(raw_input)

      expected_board = %{
        {0, 0} => :wall,
        {1, 0} => :wall,
        {2, 0} => :wall,
        {3, 0} => :wall,
        {4, 0} => :wall,
        {5, 0} => :wall,
        {6, 0} => :wall,
        {0, 1} => :wall,
        {1, 1} => %Day15.Goblin{hp: 200},
        {6, 1} => :wall,
        {0, 2} => :wall,
        {2, 2} => %Day15.Goblin{hp: 131},
        {6, 2} => :wall,
        {0, 3} => :wall,
        {2, 3} => :wall,
        {4, 3} => :wall,
        {5, 3} => %Day15.Goblin{hp: 59},
        {6, 3} => :wall,
        {0, 4} => :wall,
        {4, 4} => :wall,
        {6, 4} => :wall,
        {0, 5} => :wall,
        {5, 5} => %Day15.Goblin{hp: 200},
        {6, 5} => :wall,
        {0, 6} => :wall,
        {1, 6} => :wall,
        {2, 6} => :wall,
        {3, 6} => :wall,
        {4, 6} => :wall,
        {5, 6} => :wall,
        {6, 6} => :wall
      }

      assert fight!(board) == {expected_board, 47, 27730}
    end

    test "example 2" do
      raw_input = ~S"""
      #######
      #G..#E#
      #E#E.E#
      #G.##.#
      #...#E#
      #...E.#
      #######
      """

      board = parse_input(raw_input)

      assert {_, 37, 36334} = fight!(board)
    end

    test "example 3" do
      raw_input = ~S"""
      #######
      #E..EG#
      #.#G.E#
      #E.##E#
      #G..#.#
      #..E#.#
      #######
      """

      board = parse_input(raw_input)

      assert {_, 46, 39514} = fight!(board)
    end

    test "example 4" do
      raw_input = ~S"""
      #######
      #E.G#.#
      #.#G..#
      #G.#.G#
      #G..#.#
      #...E.#
      #######
      """

      board = parse_input(raw_input)

      assert {_, 35, 27755} = fight!(board)
    end

    test "example 5" do
      raw_input = ~S"""
      #######
      #.E...#
      #.#..G#
      #.###.#
      #E#G#G#
      #...#G#
      #######
      """

      board = parse_input(raw_input)

      assert {_, 54, 28944} = fight!(board)
    end

    test "example 6" do
      raw_input = ~S"""
      #########
      #G......#
      #.E.#...#
      #..##..G#
      #...##..#
      #...#...#
      #.G...G.#
      #.....G.#
      #########
      """

      board = parse_input(raw_input)

      assert {_, 20, 18740} = fight!(board)
    end
  end

  describe "print_board" do
    test "one example" do
      raw_input = ~S"""
      #########
      #G......#
      #.E.#...#
      #..##..G#
      #...##..#
      #...#...#
      #.G...G.#
      #.....G.#
      #########
      """

      board = parse_input(raw_input)

      assert print_board(board) == raw_input
    end
  end
end
