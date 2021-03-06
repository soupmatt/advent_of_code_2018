# Disclaimer, I followed along with @josevalim as he did his solution for puzzle 1
# https://www.twitch.tv/videos/344508213
# I did puzzle 2 on my own
defmodule Day3 do
  @type claim :: String.t
  @type parsed_claim :: list
  @type coordinate :: {pos_integer, pos_integer}
  @type id :: integer

  @doc """
  Parses a claim

  ## Examples

      iex> Day3.parse_claim("#1 @ 12,363: 8x4")
      [1, 12, 363, 8, 4]

  """
  @spec parse_claim(claim) :: parsed_claim
  def parse_claim(string) when is_binary(string) do
    string
    |> String.split(["#", " @ ", ",", ": ", "x"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Claimed inches

  ## Examples

      iex> claimed = Day3.claimed_inches([
      ...>   "#1 @ 1,3: 4x4",
      ...>   "#2 @ 3,1: 4x4",
      ...>   "#3 @ 5,5: 2x2",
      ...> ])
      iex> claimed[{4, 2}]
      [2]
      iex> claimed[{4, 4}]
      [2, 1]

  """
  @spec claimed_inches([claim]) :: %{coordinate => [id]}
  def claimed_inches(claims) do
    Enum.reduce(claims, %{}, fn claim, acc ->
      [id, left, top, width, height] = parse_claim(claim)

      Enum.reduce((left + 1)..(left + width), acc, fn x, acc ->
        Enum.reduce((top + 1)..(top + height), acc, fn y, acc ->
          Map.update(acc, {x, y}, [id], &[id | &1])
        end)
      end)
    end)
  end

  @doc """
  Retrieves overlapped inches

  ## Examples

      iex> Day3.overlapped_inches([
      ...>   "#1 @ 1,3: 4x4",
      ...>   "#2 @ 3,1: 4x4",
      ...>   "#3 @ 5,5: 2x2",
      ...> ]) |> Enum.sort()
      [{4, 4}, {4, 5}, {5, 4}, {5, 5}]
  """
  @spec overlapped_inches([claim]) :: [coordinate]
  def overlapped_inches(claims) do
    for {coordinate, [_, _ | _]} <- claimed_inches(claims), do: coordinate
  end

  @doc """
  Retrieves claims that don't have any overlap

  ## Examples

      iex> Day3.clean_claims([
      ...>   "#1 @ 1,3: 4x4",
      ...>   "#2 @ 3,1: 4x4",
      ...>   "#3 @ 5,5: 2x2",
      ...> ])
      [3]
  """
  @spec clean_claims([claim]) :: [id]
  def clean_claims(claims) do
    {overlapped_ids, all_ids} = claimed_inches(claims)
    |> Enum.reduce({MapSet.new(), MapSet.new()}, fn {_coord, ids}, {overlapped_ids, all_ids} ->
      case ids do
        [ id | [] ] ->
          {overlapped_ids, MapSet.put(all_ids, id)}
        _ ->
          Enum.reduce(ids, {overlapped_ids, all_ids}, fn id, {overlapped_ids, all_ids} ->
            {MapSet.put(overlapped_ids, id), MapSet.put(all_ids, id)}
          end)
      end
    end)
    MapSet.difference(all_ids, overlapped_ids) |> Enum.to_list()
  end
end
