defmodule Day8Test do
  use ExUnit.Case
  doctest Day8

  test "construct_tree" do
    input = [2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]

    nodeD = {0, 1, [], [99]}
    nodeC = {1, 1, [nodeD], [2]}
    nodeB = {0, 3, [], [10, 11, 12]}
    nodeA = {2, 3, [nodeB, nodeC], [1, 1, 2]}

    assert Day8.construct_tree(input) == nodeA
  end

  test "sum_metadata" do
    nodeD = {0, 1, [], [99]}
    nodeC = {1, 1, [nodeD], [2]}
    nodeB = {0, 3, [], [10, 11, 12]}
    nodeA = {2, 3, [nodeB, nodeC], [1, 1, 2]}

    assert Day8.sum_metadata(nodeA) == 138
  end

  test "node_value" do
    nodeD = {0, 1, [], [99]}
    nodeC = {1, 1, [nodeD], [2]}
    nodeB = {0, 3, [], [10, 11, 12]}
    nodeA = {2, 3, [nodeB, nodeC], [1, 1, 2]}

    assert Day8.node_value(nodeD) == 99
    assert Day8.node_value(nodeB) == 33
    assert Day8.node_value(nodeC) == 0
    assert Day8.node_value(nodeA) == 66
  end
end
