%{trace: trace, program: _} = File.read!("input.txt") |> Day16.parse_input()

trace
|> Stream.map(&Day16.test_trace/1)
|> Stream.filter(fn instrs -> length(instrs) >= 3 end)
|> Enum.to_list()
|> length()
|> IO.inspect() 
