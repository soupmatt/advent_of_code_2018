File.read!("input.txt")
|> String.split(" ", trim: true)
|> Enum.map(&String.trim/1)
|> Enum.map(&String.to_integer/1)
|> Day8.construct_tree()
|> Day8.sum_metadata()
|> IO.inspect()
