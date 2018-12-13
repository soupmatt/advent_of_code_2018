defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  setup do
    raw_rules = [
      "...## => #",
      "..#.. => #",
      ".#... => #",
      ".#.#. => #",
      ".#.## => #",
      ".##.. => #",
      ".#### => #",
      "#.#.# => #",
      "#.### => #",
      "##.#. => #",
      "##.## => #",
      "###.. => #",
      "###.# => #",
      "####. => #"
    ]

    rules =
      Enum.map(raw_rules, &Day12.parse_rule/1)
      |> Day12.compile_rules()

    [rules: rules]
  end

  describe "advance_generations" do
    test "first generation", %{rules: rules} do
      initial_state = "#..#.#..##......###...###"

      assert Day12.advance_generations(initial_state, rules, 1) ==
               {"#...#....#.....#..#..#..#", 0}
    end

    test "second generation", %{rules: rules} do
      initial_state = "#..#.#..##......###...###"

      assert Day12.advance_generations(initial_state, rules, 2) ==
               {"##..##...##....#..#..#..##", 0}
    end

    test "second generation made in two calls", %{rules: rules} do
      initial_state = "#..#.#..##......###...###"

      {first_gen_state, first_gen_pot} = Day12.advance_generations(initial_state, rules)
      second_gen = Day12.advance_generations(first_gen_state, rules, 1, first_gen_pot)
      assert second_gen == {"##..##...##....#..#..#..##", 0}
    end

    test "third generation", %{rules: rules} do
      initial_state = "#..#.#..##......###...###"

      assert Day12.advance_generations(initial_state, rules, 3) ==
               {"#.#...#..#.#....#..#..#...#", -1}
    end

    test "fifth generation", %{rules: rules} do
      initial_state = "#..#.#..##......###...###"

      assert Day12.advance_generations(initial_state, rules, 5) ==
               {"#...##...#.#..#..#...#...#", 1}
    end

    test "16th generation", %{rules: rules} do
      initial_state = "#..#.#..##......###...###"

      assert Day12.advance_generations(initial_state, rules, 16) ==
               {"#.#..#...#.#...##...#...#.#..##..##", -2}
    end

    test "20th generation", %{rules: rules} do
      initial_state = "#..#.#..##......###...###"

      assert Day12.advance_generations(initial_state, rules, 20) ==
               {"#....##....#####...#######....#.#..##", -2}
    end
  end

  describe "collect_generations" do
    test "matching advance_generations", %{rules: rules} do
      initial_state = "#..#.#..##......###...###"

      expected = [
        {initial_state, 0}
        | Enum.map(1..20, fn i ->
            Day12.advance_generations(initial_state, rules, i)
          end)
      ]

      assert Day12.collect_generations(initial_state, rules, 20) == expected
    end

    test "matching the example data", %{rules: rules} do
      initial_state = "#..#.#..##......###...###"

      expected = [
        {"#..#.#..##......###...###", 0},
        {"#...#....#.....#..#..#..#", 0},
        {"##..##...##....#..#..#..##", 0},
        {"#.#...#..#.#....#..#..#...#", -1},
        {"#.#..#...#.#...#..#..##..##", 0},
        {"#...##...#.#..#..#...#...#", 1},
        {"##.#.#....#...#..##..##..##", 1},
        {"#..###.#...##..#...#...#...#", 0},
        {"#....##.#.#.#..##..##..##..##", 0},
        {"##..#..#####....#...#...#...#", 0},
        {"#.#..#...#.##....##..##..##..##", -1},
        {"#...##...#.#...#.#...#...#...#", 0},
        {"##.#.#....#.#...#.#..##..##..##", 0},
        {"#..###.#....#.#...#....#...#...#", -1},
        {"#....##.#....#.#..##...##..##..##", -1},
        {"##..#..#.#....#....#..#.#...#...#", -1},
        {"#.#..#...#.#...##...#...#.#..##..##", -2},
        {"#...##...#.#.#.#...##...#....#...#", -1},
        {"##.#.#....#####.#.#.#...##...##..##", -1},
        {"#..###.#..#.#.#######.#.#.#..#.#...#", -2},
        {"#....##....#####...#######....#.#..##", -2}
      ]

      assert Day12.collect_generations(initial_state, rules, 20) == expected
    end
  end
end
