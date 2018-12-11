defmodule Day10Test do
  use ExUnit.Case
  doctest Day10

  describe "draw_grid_at_time" do
    test "base case" do
      assert Day10.draw_grid_at_time([], 0) == []
    end

    test "one point" do
      assert Day10.draw_grid_at_time([{{1, 1}, {1, 1}}], 0) == [
               '#'
             ]
    end

    test "two points" do
      assert Day10.draw_grid_at_time(
               [
                 {{1, 1}, {1, 1}},
                 {{2, 2}, {1, 1}}
               ],
               0
             ) == [
               '#.',
               '.#'
             ]
    end

    test "four points, full grid" do
      assert Day10.draw_grid_at_time(
               [
                 {{1, 1}, {1, 1}},
                 {{1, 2}, {1, 1}},
                 {{2, 1}, {1, 1}},
                 {{2, 2}, {1, 1}}
               ],
               0
             ) == [
               '##',
               '##'
             ]
    end

    test "simple_example" do
      points = [
        {{3, 1}, {0, 2}},
        {{2, -2}, {-1, 1}},
        {{-1, 5}, {1, -2}},
        {{5, 0}, {-2, -1}}
      ]

      assert Day10.draw_grid_at_time(points, 0) == [
               '...#...',
               '.......',
               '......#',
               '....#..',
               '.......',
               '.......',
               '.......',
               '#......'
             ]
    end

    # test "simple_example advanced 1 second" do
    #   points = [
    #     {{3, 1}, {0, 2}},
    #     {{2, -2}, {-1, 1}},
    #     {{-1, 5}, {1, -2}},
    #     {{5, 0}, {-2, -1}}
    #   ]
    #
    #   assert Day10.draw_grid_at_time(points, 1) == [
    #            '#......',
    #            '.......',
    #            '.......',
    #            '.......',
    #            '....#..',
    #            '......#',
    #            '.......',
    #            '...#...'
    #          ]
    # end
  end

  describe "sort_points" do
    test "y goes bottom to top" do
      points = [
        {{1, 1}, {1, 1}},
        {{1, -1}, {1, 1}},
        {{1, 2}, {1, 1}}
      ]

      assert Day10.sort_points(points) == [
               {{1, 2}, {1, 1}},
               {{1, 1}, {1, 1}},
               {{1, -1}, {1, 1}}
             ]
    end

    test "x goes right to left" do
      points = [
        {{1, 1}, {1, 1}},
        {{5, 1}, {1, 1}},
        {{-2, 1}, {1, 1}}
      ]

      assert Day10.sort_points(points) == [
               {{5, 1}, {1, 1}},
               {{1, 1}, {1, 1}},
               {{-2, 1}, {1, 1}}
             ]
    end

    test "sort by y, then x" do
      points = [
        {{1, 1}, {1, 1}},
        {{1, 2}, {1, 1}},
        {{2, 1}, {1, 1}},
        {{2, 2}, {1, 1}}
      ]

      assert Day10.sort_points(points) == [
               {{2, 2}, {1, 1}},
               {{1, 2}, {1, 1}},
               {{2, 1}, {1, 1}},
               {{1, 1}, {1, 1}}
             ]
    end
  end

  describe "testing the example grid" do
    setup do
      [
        records:
          [
            "position=< 9,  1> velocity=< 0,  2>",
            "position=< 7,  0> velocity=<-1,  0>",
            "position=< 3, -2> velocity=<-1,  1>",
            "position=< 6, 10> velocity=<-2, -1>",
            "position=< 2, -4> velocity=< 2,  2>",
            "position=<-6, 10> velocity=< 2, -2>",
            "position=< 1,  8> velocity=< 1, -1>",
            "position=< 1,  7> velocity=< 1,  0>",
            "position=<-3, 11> velocity=< 1, -2>",
            "position=< 7,  6> velocity=<-1, -1>",
            "position=<-2,  3> velocity=< 1,  0>",
            "position=<-4,  3> velocity=< 2,  0>",
            "position=<10, -3> velocity=<-1,  1>",
            "position=< 5, 11> velocity=< 1, -2>",
            "position=< 4,  7> velocity=< 0, -1>",
            "position=< 8, -2> velocity=< 0,  1>",
            "position=<15,  0> velocity=<-2,  0>",
            "position=< 1,  6> velocity=< 1,  0>",
            "position=< 8,  9> velocity=< 0, -1>",
            "position=< 3,  3> velocity=<-1,  1>",
            "position=< 0,  5> velocity=< 0, -1>",
            "position=<-2,  2> velocity=< 2,  0>",
            "position=< 5, -2> velocity=< 1,  2>",
            "position=< 1,  4> velocity=< 2,  1>",
            "position=<-2,  7> velocity=< 2, -2>",
            "position=< 3,  6> velocity=<-1, -1>",
            "position=< 5,  0> velocity=< 1,  0>",
            "position=<-6,  0> velocity=< 2,  0>",
            "position=< 5,  9> velocity=< 1, -2>",
            "position=<14,  7> velocity=<-2,  0>",
            "position=<-3,  6> velocity=< 2, -1>"
          ]
          |> Enum.map(&Day10.parse_record/1)
      ]
    end

    test "draw at zero seconds", context do
      records = context[:records]

      assert Day10.draw_grid_at_time(records, 0) ==
               [
                 '........#.............',
                 '................#.....',
                 '.........#.#..#.......',
                 '......................',
                 '#..........#.#.......#',
                 '...............#......',
                 '....#.................',
                 '..#.#....#............',
                 '.......#..............',
                 '......#...............',
                 '...#...#.#...#........',
                 '....#..#..#.........#.',
                 '.......#..............',
                 '...........#..#.......',
                 '#...........#.........',
                 '...#.......#..........'
               ]
    end

    test "draw at three seconds", context do
      records = context[:records]

      result = Day10.draw_grid_at_time(records, 3)

      assert result == [
               '#...#..###',
               '#...#...#.',
               '#...#...#.',
               '#####...#.',
               '#...#...#.',
               '#...#...#.',
               '#...#...#.',
               '#...#..###'
             ]
    end

    test "find the smallest bounds", context do
      records = context[:records]

      {count, _, _, _} = Day10.find_minimum_bounds(records)
      assert count == 3
    end
  end
end
