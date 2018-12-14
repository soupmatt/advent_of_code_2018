{cars, tracks} =
  File.read!('input.txt')
  |> Day13.parse_input()

Day13.find_collision(cars, tracks)
|> IO.inspect() 
