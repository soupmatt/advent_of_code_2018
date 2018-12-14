defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  def from_fixture(file_name) do
    File.read!("test/fixtures/#{file_name}.txt")
    |> Day13.parse_input()
  end

  def strip_car_next_turns(cars) do
    Enum.map(cars, fn {coord, {dir, _}} -> {coord, dir} end)
    |> Enum.sort()
  end

  describe "find_collision" do
    test "the example" do
      {cars, tracks} = from_fixture("example_start")

      assert Day13.find_collision(cars, tracks) == {7, 3}
    end
  end

  describe "parse_input" do
    test "the example" do
      {cars, tracks} =
        File.read!("test/fixtures/example_start.txt")
        |> Day13.parse_input()

      assert cars == %{
               {0, 2} => {?>, :left},
               {3, 9} => {?v, :left}
             }

      assert tracks == %{
               {0, 0} => ?/,
               {0, 1} => ?-,
               {0, 2} => ?-,
               {0, 3} => ?-,
               {0, 4} => ?\\,
               {1, 0} => ?|,
               {1, 4} => ?|,
               {1, 7} => ?/,
               {1, 8} => ?-,
               {1, 9} => ?-,
               {1, 10} => ?-,
               {1, 11} => ?-,
               {1, 12} => ?\\,
               {2, 0} => ?|,
               {2, 2} => ?/,
               {2, 3} => ?-,
               {2, 4} => ?+,
               {2, 5} => ?-,
               {2, 6} => ?-,
               {2, 7} => ?+,
               {2, 8} => ?-,
               {2, 9} => ?\\,
               {2, 12} => ?|,
               {3, 0} => ?|,
               {3, 2} => ?|,
               {3, 4} => ?|,
               {3, 7} => ?|,
               {3, 9} => ?|,
               {3, 12} => ?|,
               {4, 0} => ?\\,
               {4, 1} => ?-,
               {4, 2} => ?+,
               {4, 3} => ?-,
               {4, 4} => ?/,
               {4, 7} => ?\\,
               {4, 8} => ?-,
               {4, 9} => ?+,
               {4, 10} => ?-,
               {4, 11} => ?-,
               {4, 12} => ?/,
               {5, 2} => ?\\,
               {5, 3} => ?-,
               {5, 4} => ?-,
               {5, 5} => ?-,
               {5, 6} => ?-,
               {5, 7} => ?-,
               {5, 8} => ?-,
               {5, 9} => ?/
             }
    end

    test "all the cars" do
      input = ~S"""
      /->-\
      |   |
      ^   v
      |   |
      \-<-/
      """

      {cars, tracks} = Day13.parse_input(input)

      assert cars == %{
               {0, 2} => {?>, :left},
               {2, 0} => {?^, :left},
               {2, 4} => {?v, :left},
               {4, 2} => {?<, :left}
             }

      assert match?(
               %{
                 {0, 2} => ?-,
                 {2, 0} => ?|,
                 {2, 4} => ?|,
                 {4, 2} => ?-
               },
               tracks
             )
    end
  end

  describe "next_tick" do
    test "example tick 1" do
      {input_cars, tracks} = from_fixture("example_start")

      {expected_cars, _} = from_fixture("example_tick_1")

      {:ok, result_cars} = Day13.next_tick(input_cars, tracks)

      assert strip_car_next_turns(result_cars) == strip_car_next_turns(expected_cars)
    end

    test "check each tick" do
      {input_cars, tracks} = from_fixture("example_start")

      expected =
        Enum.reduce(1..13, [], fn i, acc ->
          {cars, _} = from_fixture("example_tick_#{i}")
          [strip_car_next_turns(cars) | acc]
        end)
        |> Enum.reverse()

      {final_cars, 14} =
        Enum.reduce(expected, {input_cars, 1}, fn expected_cars, {input_cars, tick} ->
          case Day13.next_tick(input_cars, tracks) do
            {:ok, new_cars} ->
              assert strip_car_next_turns(new_cars) == expected_cars, "failed at tick #{tick}"
              {new_cars, tick + 1}

            {:crash, coord} ->
              flunk("failed at tick #{tick} with a crash at coord #{inspect(coord)}")
          end
        end)

      assert Day13.next_tick(final_cars, tracks) == {:crash, {3, 7}}
    end
  end

  describe "next_tick with remove_cars set" do
    test "example tick 1" do
      {input_cars, tracks} = from_fixture("example2_start")

      {expected_cars, _} = from_fixture("example2_tick_1")

      {:ok, result_cars} = Day13.next_tick(input_cars, tracks, [remove_cars: true])

      assert strip_car_next_turns(result_cars) == strip_car_next_turns(expected_cars)
    end

    test "check each tick" do
      {input_cars, tracks} = from_fixture("example2_start")

      expected =
        Enum.reduce(1..2, [], fn i, acc ->
          {cars, _} = from_fixture("example2_tick_#{i}")
          [strip_car_next_turns(cars) | acc]
        end)
        |> Enum.reverse()

      {final_cars, 3} =
        Enum.reduce(expected, {input_cars, 1}, fn expected_cars, {input_cars, tick} ->
          case Day13.next_tick(input_cars, tracks, [remove_cars: true]) do
            {:ok, new_cars} ->
              assert strip_car_next_turns(new_cars) == expected_cars, "failed at tick #{tick}"
              {new_cars, tick + 1}

            {:crash, coord} ->
              flunk("failed at tick #{tick} with a crash at coord #{inspect(coord)}")

            {:last_car, coord} ->
              flunk("failed at tick #{tick} with last car at coord #{inspect(coord)}")
          end
        end)

      assert Day13.next_tick(final_cars, tracks, [remove_cars: true]) == {:last_car, {4, 6}}
    end
  end
end
