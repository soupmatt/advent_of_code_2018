coordinates = File.read!("input.txt") |> String.split("\n", trim: true)
|> Day6.parse_coordinates()

IO.inspect Day6.close_region_size(coordinates, 10000)
