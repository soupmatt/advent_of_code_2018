defmodule Day9 do
  @type player :: pos_integer
  @type marble :: pos_integer
  @type board :: [marble]
  @type players :: [player]

  import NimbleParsec

  @doc """
  parse the input string

  ## Examples

      iex> Day9.parse_input("10 players; last marble is worth 1618 points")
      {10, 1618}

      iex> Day9.parse_input("13 players; last marble is worth 7999 points")
      {13, 7999}

      iex> Day9.parse_input("17 players; last marble is worth 1104 points")
      {17, 1104}

      iex> Day9.parse_input("21 players; last marble is worth 6111 points")
      {21, 6111}

      iex> Day9.parse_input("30 players; last marble is worth 5807 points")
      {30, 5807}

  """
  @spec parse_input(String.t()) :: {integer, integer}
  def parse_input(input) do
    {:ok, [num_players, max_marble], _, _, _, _} = parse_game_parameters(input)
    {num_players, max_marble}
  end

  defparsecp(
    :parse_game_parameters,
    integer(min: 1)
    |> ignore(string(" players; last marble is worth "))
    |> integer(min: 1)
    |> ignore(string(" points"))
  )

  @doc """
  score the marble game

  ## Examples

      iex> Day9.score_marble_game(9, 25)
      32

      iex> Day9.score_marble_game(10, 1618)
      8317

      iex> Day9.score_marble_game(13, 7999)
      146373

      iex> Day9.score_marble_game(17, 1104)
      2764

      iex> Day9.score_marble_game(21, 6111)
      54718

      iex> Day9.score_marble_game(30, 5807)
      37305

  """
  @spec score_marble_game(pos_integer, pos_integer) :: pos_integer
  def score_marble_game(num_players, max_marble) do
    {players, _} = run_game(num_players, max_marble)
    Enum.max(players)
  end

  @spec run_game(pos_integer, pos_integer) :: {players, board}
  def run_game(num_players, max_marble) when num_players >= 1 and max_marble >= 1 do
    run_game(List.duplicate(0, num_players), [], [], [0], 1, max_marble)
  end

  # cycle the players back around
  @spec run_game(players, players, board, board, marble, marble) :: {players, board}
  defp run_game([], players_gone, counter_board, clockwise_board, next_marble, max_marble) do
    run_game(
      Enum.reverse(players_gone),
      [],
      counter_board,
      clockwise_board,
      next_marble,
      max_marble
    )
  end

  # base case
  @spec run_game(players, players, board, board, marble, marble) :: {players, board}
  defp run_game(
         players_to_go,
         players_gone,
         counter_board,
         clockwise_board,
         next_marble,
         max_marble
       )
       when next_marble > max_marble do
    {Enum.reverse(players_gone, players_to_go), clockwise_board ++ Enum.reverse(counter_board)}
  end

  @spec run_game(players, players, board, board, marble, marble) :: {players, board}
  defp run_game(
         [next_player | players_to_go],
         players_gone,
         counter_board,
         clockwise_board,
         next_marble,
         max_marble
       ) do
    {counter_board, clockwise_board, points_awarded} =
      add_marble_to_board(counter_board, clockwise_board, next_marble)

    run_game(
      players_to_go,
      [next_player + points_awarded | players_gone],
      counter_board,
      clockwise_board,
      next_marble + 1,
      max_marble
    )
  end

  @spec add_marble_to_board(board, board, marble) :: {board, board, pos_integer}
  def add_marble_to_board(counter_board, clockwise_board, next_marble) when next_marble <= 2 do
    {counter_board, [next_marble | clockwise_board], 0}
  end

  @spec add_marble_to_board(board, board, marble) :: {board, board, pos_integer}
  def add_marble_to_board(counter_board, [current | []], next_marble) do
    {counter_board, counter_tail} = split_list(counter_board)
    add_marble_to_board(counter_board, [current | counter_tail], next_marble)
  end

  # scoring turn
  @spec add_marble_to_board(board, board, marble) :: {board, board, pos_integer}
  def add_marble_to_board(counter_board, clockwise_board, next_marble)
      when rem(next_marble, 23) == 0 do
    {counter_board, clockwise_board, points} = remove_marble(counter_board, clockwise_board, 7)
    {counter_board, clockwise_board, points + next_marble}
  end

  # non-scoring turn
  @spec add_marble_to_board(board, board, marble) :: {board, board, pos_integer}
  def add_marble_to_board(
        counter_board,
        [old_current, one_clockwise | clockwise_board],
        next_marble
      ) do
    {[one_clockwise, old_current | counter_board], [next_marble | clockwise_board], 0}
  end

  @spec split_list(board) :: {board, board}
  def split_list([]) do
    {[], []}
  end

  @spec split_list(board) :: {board, board}
  def split_list([elem | []]) do
    {[], [elem]}
  end

  @spec split_list(board) :: {board, board}
  def split_list([e1, e2 | []]) do
    {[e1 | []], [e2 | []]}
  end

  @spec split_list(board) :: {board, board}
  def split_list([e1, e2, e3 | []]) do
    {[e1, e2 | []], [e3 | []]}
  end

  @spec split_list(board) :: {board, board}
  def split_list(board) when length(board) <= 9 do
    split_list2(board)
  end

  @spec split_list(board) :: {board, board}
  def split_list([e1, e2, e3, e4, e5, e6, e7 | board]) do
    {[e1, e2, e3, e4, e5, e6, e7 | []], Enum.reverse(board)}
  end

  defp split_list2([e1, e2, e3 | []]) do
    {[e1], [e3, e2]}
  end

  defp split_list2([head | board]) do
    {left, right} = split_list2(board)
    {[head | left], right}
  end

  @spec remove_marble(board, board, non_neg_integer) :: {board, board, pos_integer}
  def remove_marble([c_head | counter_board], clockwise_board, 1) do
    {counter_board, clockwise_board, c_head}
  end

  @spec remove_marble(board, board, non_neg_integer) :: {board, board, pos_integer}
  def remove_marble([c_head | counter_board], clockwise_board, count) do
    remove_marble(counter_board, [c_head | clockwise_board], count - 1)
  end
end
