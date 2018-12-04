file = File.read!('day3_input.txt')
claims = String.split(file, "\n", trim: true)
IO.inspect Day3.clean_claims(claims)
