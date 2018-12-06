File.read!("input.txt") |> String.split("\n", trim: true)
|> Day6.parse_coordinates()
|> Day6.coordinate_zone_sizes()
|> Enum.max_by(fn
  {_, :infinite} ->
    0
  {_, val} ->
    val
end)
|> IO.inspect()
