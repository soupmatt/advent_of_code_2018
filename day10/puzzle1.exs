initial_points = File.read!('input.txt')
|> String.split("\n", trim: true)
|> Enum.map(&Day10.parse_record/1)

{iterations, size, _, points} = Day10.find_minimum_bounds(initial_points)

IO.puts "smallest found after #{iterations} seconds with a size of #{size}"

Day10.draw_grid_at_time(points)
|> IO.inspect()
