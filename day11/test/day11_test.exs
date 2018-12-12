defmodule Day11Test do
  use ExUnit.Case
  doctest Day11

  @tag timeout: 10 * 60 * 1000
  test "max_power_point 18" do
    assert Day11.max_power_point(18) == {{90, 269, 16}, 113}
  end

  @tag timeout: 10 * 60 * 1000
  test "max_power_point 42" do
    assert Day11.max_power_point(42) == {{232, 251, 12}, 119}
  end
end
