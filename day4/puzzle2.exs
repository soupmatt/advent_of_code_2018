file = File.read!('input.txt')
records = String.split(file, "\n", trim: true) |> Enum.sort()
data = Day4.parse_records(records) |> Enum.reject(fn {_, minutes} -> Map.equal?(%{}, minutes) end)

guard_minutes = Enum.map(data, fn {id, minutes} ->
  {most_popular_minute, count} = Enum.max_by(minutes, fn {_, count} -> count end)
  {id, most_popular_minute, count}
end)
best_guard = Enum.max_by(guard_minutes, fn {_, _, count} -> count end)

IO.inspect best_guard

{id, most_popular_minute, count} = best_guard

IO.puts "The winning guard is " <> Integer.to_string(id) <> " who was asleep " <> Integer.to_string(count) <> " times at " <> Integer.to_string(most_popular_minute)

IO.puts "the puzzle solution is " <> Integer.to_string(id * most_popular_minute) 
