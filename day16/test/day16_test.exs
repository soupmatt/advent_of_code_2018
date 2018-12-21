defmodule Day16Test do
  use ExUnit.Case
  doctest Day16

  describe "parse_trace" do
    test "1 element" do
      input = ~S"""
      Before: [1, 2, 3, 3]
      1 1 2 3
      After:  [1, 2, 3, 4]
      """

      assert Day16.parse_trace(input) == [
               {
                 [1, 2, 3, 3],
                 {1, 1, 2, 3},
                 [1, 2, 3, 4]
               }
             ]
    end

    test "3 elements" do
      input = ~S"""
      Before: [3, 0, 1, 3]
      15 2 1 3
      After:  [3, 0, 1, 1]

      Before: [1, 3, 2, 0]
      11 2 2 0
      After:  [4, 3, 2, 0]

      Before: [0, 3, 3, 1]
      14 3 2 0
      After:  [3, 3, 3, 1]
      """

      assert Day16.parse_trace(input) == [
               {
                 [3, 0, 1, 3],
                 {15, 2, 1, 3},
                 [3, 0, 1, 1]
               },
               {
                 [1, 3, 2, 0],
                 {11, 2, 2, 0},
                 [4, 3, 2, 0]
               },
               {
                 [0, 3, 3, 1],
                 {14, 3, 2, 0},
                 [3, 3, 3, 1]
               }
             ]
    end
  end

  describe "test_trace" do
    test "first example" do
      assert Day16.test_trace({
               [0, 3, 3, 1],
               {14, 3, 2, 0},
               [3, 3, 3, 1]
             }) == [:seti, :mulr, :borr, :bori, :addi]
    end
  end
end
