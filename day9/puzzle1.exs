{num_players, max_marble} = File.read!("input.txt")
|> Day9.parse_input()

Day9.score_marble_game(num_players, max_marble)
|> IO.inspect() 
