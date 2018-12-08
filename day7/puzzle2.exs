File.read!('input.txt')
|> String.split("\n", trim: true)
|> Day7.assemble_sleigh_timed(5, 60)
|> IO.inspect()
