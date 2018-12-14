{cars, tracks} =
  File.read!('input.txt')
  |> Day13.parse_input()

Day13.find_last_car(cars, tracks)
|> IO.inspect()
