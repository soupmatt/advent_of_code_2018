File.read!("input.txt")
|> Day15.parse_input()
|> Day15.fight!()
|> IO.inspect()
