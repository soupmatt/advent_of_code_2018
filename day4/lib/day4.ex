defmodule Day4 do
  @type record :: String.t()
  @type id :: pos_integer
  @type guard_record :: {:guard, id}
  @type minute :: pos_integer
  @type time_record :: {:sleep | :wake, minute}
  @type any_record :: guard_record | time_record
  @type compiled_records :: %{id => [time_record]}
  @type minute_records :: %{minute => pos_integer}
  @type parsed_records :: %{guard_record => minute_records}

  @doc """
  parses the records
  """
  @spec parse_records([record]) :: parsed_records
  def parse_records(records) do
    Enum.map(records, fn record ->
      if String.contains?(record, "Guard") do
        parse_guard_record(record)
      else
        parse_time_record(record)
      end
    end)
    |> compile_records()
    |> Map.new(fn {id, times} ->
      {id, records_to_time_counts(times)}
    end)
  end

  @spec compile_records([any_record]) :: compiled_records
  def compile_records([{:guard, id} | recs]) do
    compile_records({Map.new(), [], id}, recs)
  end

  defp compile_records({acc, times, id}, [{:sleep, time} | recs]) do
    compile_records({acc, [{:sleep, time} | times], id}, recs)
  end

  defp compile_records({acc, times, id}, [{:wake, time} | recs]) do
    compile_records({acc, [{:wake, time} | times], id}, recs)
  end

  defp compile_records({acc, times, id}, [{:guard, new_id} | recs]) do
    times = Enum.reverse(times)

    updated_acc =
      Map.update(acc, id, times, fn val ->
        val ++ times
      end)

    compile_records({updated_acc, [], new_id}, recs)
  end

  defp compile_records({acc, times, id}, []) do
    times = Enum.reverse(times)

    updated_acc =
      Map.update(acc, id, times, fn val ->
        val ++ times
      end)

    updated_acc
  end

  @spec records_to_time_counts([time_record]) :: minute_records
  def records_to_time_counts(records) do
    records_to_time_counts(Map.new(), records)
  end

  defp records_to_time_counts(acc, [{:sleep, sleep}, {:wake, wake} | records]) do
    updated_acc =
      Enum.reduce(sleep..(wake - 1), acc, fn i, acc ->
        Map.update(acc, i, 1, fn x -> x + 1 end)
      end)

    records_to_time_counts(updated_acc, records)
  end

  defp records_to_time_counts(acc, []) do
    acc
  end

  @doc """
  parses a guard record

  ## Examples

      iex> Day4.parse_guard_record("[1518-09-17 23:48] Guard #1307 begins shift")
      {:guard, 1307}
      iex> Day4.parse_guard_record("[1518-11-21 00:02] Guard #1459 begins shift")
      {:guard, 1459}
      iex> Day4.parse_guard_record("[1518-09-24 00:00] Guard #389 begins shift")
      {:guard, 389}

  """
  @spec parse_guard_record(record) :: guard_record
  def parse_guard_record(record) do
    id =
      String.split(record)
      |> Enum.at(3)
      |> String.split("#")
      |> List.last()
      |> String.to_integer()

    {:guard, id}
  end

  @doc """
  parses a time record

  ## Examples

      iex> Day4.parse_time_record("[1518-11-02 00:40] falls asleep")
      {:sleep, 40}
      iex> Day4.parse_time_record("[1518-11-02 00:50] wakes up")
      {:wake, 50}

  """
  @spec parse_time_record(record) :: time_record
  def parse_time_record(record) do
    case String.split(record, [" 00:", "] "]) do
      [_, time, "falls asleep"] ->
        {:sleep, String.to_integer(time)}

      [_, time, "wakes up"] ->
        {:wake, String.to_integer(time)}
    end
  end

  @spec guard_with_most_sleep(parsed_records) :: id
  def guard_with_most_sleep(data) do
    {id, _} =
      Enum.max_by(data, fn {_, minutes} ->
        Map.values(minutes) |> Enum.sum()
      end)

    id
  end
end
