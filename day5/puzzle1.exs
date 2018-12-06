file = File.read!('input.txt') |> String.trim()
result = Day5.collapse_string(file)
IO.puts String.length(result)
