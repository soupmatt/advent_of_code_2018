[initial_state_str, _ | raw_rules] =
  File.read!("input.txt")
  |> String.split("\n", trim: true)

initial_state = Day12.parse_initial_state(initial_state_str)
|> IO.inspect()
rules = Enum.map(raw_rules, &Day12.parse_rule/1) |> Day12.compile_rules()
|> IO.inspect()

{generation20, first_pot} = Day12.advance_generations(initial_state, rules, 20)
|> IO.inspect()

Day12.count_plants(generation20, first_pot)
|> IO.inspect() 
