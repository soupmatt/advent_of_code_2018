file = File.read!('input.txt')
result = Day5.collapse_string(String.trim(file))
IO.puts String.length(result)
