%{trace: traces, program: program} = File.read!("input.txt") |> Day16.parse_input()

Day16.run_program(traces, program)
|> IO.inspect()
