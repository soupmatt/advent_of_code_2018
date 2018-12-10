defmodule Day9Test do
  use ExUnit.Case
  doctest Day9

  describe "run_game" do
    test "smallest case" do
      assert Day9.run_game(1, 1) == {[0], [1, 0]}
    end

    test "take a few turns" do
      assert Day9.run_game(1, 2) == {[0], [2, 1, 0]}
      assert Day9.run_game(1, 3) == {[0], [3, 0, 2, 1]}
      assert Day9.run_game(1, 4) == {[0], [4, 2, 1, 3, 0]}
      assert Day9.run_game(1, 5) == {[0], [5, 1, 3, 0, 4, 2]}

      assert Day9.run_game(1, 22) ==
               {[0],
                [22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0, 16, 8, 17, 4, 18, 9, 19, 2, 20, 10, 21, 5]}
    end

    test "scoring turns" do
      assert Day9.run_game(1, 23) ==
               {[32],
                [19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15, 0, 16, 8, 17, 4, 18]}
    end
  end

  describe "split_list" do
    test "base_case" do
      input = [0]
      assert Day9.split_list(input) == {[], [0]}
    end

    test "2 elements" do
      input = [0, 1]
      assert Day9.split_list(input) == {[0], [1]}
    end

    test "3 elements" do
      input = [0, 1, 2]
      assert Day9.split_list(input) == {[0, 1], [2]}
    end

    test "4 elements" do
      input = [0, 1, 2, 3]
      assert Day9.split_list(input) == {[0, 1], [3, 2]}
    end

    test "5 elements" do
      input = [0, 1, 2, 3, 4]
      assert Day9.split_list(input) == {[0, 1, 2], [4, 3]}
    end

    test "6 elements" do
      input = [0, 1, 2, 3, 4, 5]
      assert Day9.split_list(input) == {[0, 1, 2, 3], [5, 4]}
    end

    test "7 elements" do
      input = [0, 1, 2, 3, 4, 5, 6]
      assert Day9.split_list(input) == {[0, 1, 2, 3, 4], [6, 5]}
    end

    test "8 elements" do
      input = [0, 1, 2, 3, 4, 5, 6, 7]
      assert Day9.split_list(input) == {[0, 1, 2, 3, 4, 5], [7, 6]}
    end

    test "9 elements" do
      input = [0, 1, 2, 3, 4, 5, 6, 7, 8]
      assert Day9.split_list(input) == {[0, 1, 2, 3, 4, 5, 6], [8, 7]}
    end

    test "10 elements" do
      input = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      assert Day9.split_list(input) == {[0, 1, 2, 3, 4, 5, 6], [9, 8, 7]}
    end
  end
end
