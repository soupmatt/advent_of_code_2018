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
      assert Day9.run_game(1, 4) == {[0], [4, 2, 1, 3, 0]}

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
end
