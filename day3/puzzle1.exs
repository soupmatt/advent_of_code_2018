file = File.read!('day3_input.txt')
claims = String.split(file, "\n", trim: true)
IO.puts Day3.overlapped_inches(claims) |> length
