board =
File.read!("input.txt")
|> Day15.parse_input()

{board, count} = Enum.reduce_while(0..1000, board, fn count, board ->
  IO.puts "Round #{count} ======================"
  IO.puts Day15.print_board(board)
  # Process.sleep(3_000)
  case Day15.run_round(board) do
    {:ok, board} ->
      {:cont, board}
    {:no_targets, board} ->
      {:halt, {board, count}}
  end
end)

IO.puts "======================="
IO.puts "Round #{count} was in progress"
IO.puts Day15.print_board(board)

IO.puts ""

IO.puts Day15.score_fight(board, count)
