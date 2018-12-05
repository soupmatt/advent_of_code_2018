file = File.read!('input.txt')
records = String.split(file, "\n", trim: true) |> Enum.sort()
data = Day4.parse_records(records)
winning_id = Day4.guard_with_most_sleep(data)
IO.puts "the guard with the most sleep is " <> Integer.to_string(winning_id)

{most_popular_minute, _} = data[winning_id]
  |> Enum.max_by(fn {_, count} -> count end)

IO.puts "His favorite minute is " <> Integer.to_string(most_popular_minute)

IO.puts "The product of those two numbers is " <> Integer.to_string(winning_id * most_popular_minute) 
