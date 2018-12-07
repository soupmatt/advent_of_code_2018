File.read!('input.txt')
|> String.split("\n", trim: true)
|> Day7.assemble_sleigh()
|> IO.inspect()
