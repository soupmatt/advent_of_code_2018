defmodule Day5 do
  @doc """
  collapse all matches in a string

  ## Examples

      iex> Day5.collapse_string("aA")
      ""

      iex> Day5.collapse_string("Aa")
      ""

      iex> Day5.collapse_string("AA")
      "AA"

      iex> Day5.collapse_string("aa")
      "aa"

      iex> Day5.collapse_string("aaB")
      "aaB"

      iex> Day5.collapse_string("aAB")
      "B"

      iex> Day5.collapse_string("baA")
      "b"

      iex> Day5.collapse_string("baAB")
      ""

      iex> Day5.collapse_string("dabAcCaCBAcCcaDA")
      "dabCBAcaDA"

      iex> Day5.collapse_string("dabAcCaCBAcCcaDAgGahenNnrpPR")
      "dabCBAcaDhen"

  """
  @spec collapse_string(String.t()) :: String.t()
  def collapse_string(string) do
    collapse_string([], String.to_charlist(string))
  end

  defp collapse_string(acc, [a, b | rest]) when a in ?a..?z and b in ?A..?Z do
    if String.downcase(to_string([b])) == to_string([a]) do
      if match?([], acc) do
        collapse_string(acc, rest)
      else
        [prev | new_acc] = acc
        collapse_string(new_acc, [prev | rest])
      end
    else
      collapse_string([a | acc], [b | rest])
    end
  end

  defp collapse_string(acc, [a, b | rest]) when b in ?a..?z and a in ?A..?Z do
    if String.capitalize(to_string([b])) == to_string([a]) do
      if match?([], acc) do
        collapse_string(acc, rest)
      else
        [prev | new_acc] = acc
        collapse_string(new_acc, [prev | rest])
      end
    else
      collapse_string([a | acc], [b | rest])
    end
  end

  defp collapse_string(acc, [a, b | rest]) do
    collapse_string([a | acc], [b | rest])
  end

  defp collapse_string(acc, rest) do
    to_string(Enum.reverse(acc) ++ rest)
  end

  @doc """
  Strip All Cases of a given character out of a string, case-insensitively

  ## Examples

      iex> Day5.strip_char("aA", ?a)
      ""

      iex> Day5.strip_char("aAb", ?a)
      "b"

      iex> Day5.strip_char("aAbcDrkaSDNefjEnsefAsa", ?a)
      "bcDrkSDNefjEnsefs"

  """
  @spec strip_char(String.t, String.codepoint) :: String.t
  def strip_char(string, to_remove) do
    str = to_string([to_remove])
    upper = String.capitalize(str)
    lower = String.downcase(str)
    String.replace(string, upper, "") |> String.replace(lower, "")
  end
end
