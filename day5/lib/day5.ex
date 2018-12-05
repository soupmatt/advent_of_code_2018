defmodule Day5 do
  @doc """
  collapse next match

  ## Examples

      iex> Day5.collapse_next_match("dabAcCaCBAcCcaDA")
      {:ok, "dabAaCBAcCcaDA"}

      iex> Day5.collapse_next_match("dabAaCBAcCcaDA")
      {:ok, "dabCBAcCcaDA"}

      iex> Day5.collapse_next_match("dabCBAcCcaDA")
      {:ok, "dabCBAcaDA"}

      iex> Day5.collapse_next_match("dabCBAcaDA")
      :no_change

      iex> Day5.collapse_next_match("q")
      :no_change

  """
  @spec collapse_next_match(String.t()) :: {:ok, String.t()} | :no_change
  def collapse_next_match(string) do
    case collapse_next_match([], to_charlist(string), 0) do
      x when is_atom(x) ->
        x

      x ->
        {:ok, to_string(x)}
    end
  end

  defp collapse_next_match(head, [a, b | rest], position) when a in ?a..?z and b in ?A..?Z do
    if String.downcase(to_string([b])) == to_string([a]) do
      Enum.reverse(head) ++ rest
    else
      collapse_next_match([a | head], [b | rest], position + 1)
    end
  end

  defp collapse_next_match(head, [a, b | rest], position) when a in ?A..?A and b in ?a..?z do
    if String.capitalize(to_string([b])) == to_string([a]) do
      Enum.reverse(head) ++ rest
    else
      collapse_next_match([a | head], [b | rest], position + 1)
    end
  end

  defp collapse_next_match(head, [a, b | rest], position) do
    collapse_next_match([a | head], [b | rest], position + 1)
  end

  defp collapse_next_match(_, [_ | []], _) do
    :no_change
  end

  @doc """
  collapse all matches in a string

  ## Examples

      iex> Day5.collapse_string("dabAcCaCBAcCcaDA")
      "dabCBAcaDA"

      iex> Day5.collapse_string("dabAcCaCBAcCcaDAgGahenNnrpPR")
      "dabCBAcaDhen"

  """
  @spec collapse_string(String.t()) :: String.t()
  def collapse_string(input) do
    case collapse_next_match(input) do
      {:ok, result} ->
        collapse_string(result)

      :no_change ->
        input
    end
  end
end
