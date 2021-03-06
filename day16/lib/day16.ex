defmodule Day16 do
  use Bitwise
  import NimbleParsec

  def new_machine(values \\ [0, 0, 0, 0]) do
    values
    |> Stream.with_index()
    |> Stream.map(fn {value, index} -> {index, value} end)
    |> Map.new()
  end

  def registers(machine) do
    machine
    |> Enum.sort_by(fn {index, _value} -> index end)
    |> Enum.map(fn {_index, value} -> value end)
  end

  defp get_reg(machine, index), do: Map.get(machine, index)
  defp set_reg(machine, index, value), do: Map.put(machine, index, value)

  @doc """

  ## Examples

      iex> Day16.addr(Day16.new_machine([3, 2, 7, 5]), 1, 0, 2) |> Day16.registers()
      [3, 2, 5, 5]

      iex> Day16.addr(Day16.new_machine([1, 2, 3, 6]), 3, 2, 1) |> Day16.registers()
      [1, 9, 3, 6]

  """
  def addr(machine, a, b, c) do
    set_reg(machine, c, get_reg(machine, a) + get_reg(machine, b))
  end

  @doc """

  ## Examples

      iex> Day16.addi(Day16.new_machine([3, 2, 7, 5]), 1, 1, 2) |> Day16.registers()
      [3, 2, 3, 5]

      iex> Day16.addi(Day16.new_machine([1, 2, 3, 6]), 2, 2, 1) |> Day16.registers()
      [1, 5, 3, 6]

  """
  def addi(machine, a, b, c) do
    set_reg(machine, c, get_reg(machine, a) + b)
  end

  @doc """

  ## Examples

      iex> Day16.mulr(Day16.new_machine([3, 2, 7, 5]), 1, 0, 2) |> Day16.registers()
      [3, 2, 6, 5]

      iex> Day16.mulr(Day16.new_machine([1, 2, 3, 6]), 2, 3, 0) |> Day16.registers()
      [18, 2, 3, 6]

  """
  def mulr(machine, a, b, c) do
    set_reg(machine, c, get_reg(machine, a) * get_reg(machine, b))
  end

  @doc """

  ## Examples

      iex> Day16.muli(Day16.new_machine([3, 2, 7, 5]), 1, 0, 2) |> Day16.registers()
      [3, 2, 0, 5]

      iex> Day16.muli(Day16.new_machine([1, 2, 3, 6]), 2, 3, 0) |> Day16.registers()
      [9, 2, 3, 6]

  """
  def muli(machine, a, b, c) do
    set_reg(machine, c, get_reg(machine, a) * b)
  end

  def banr(machine, a, b, c) do
    set_reg(machine, c, band(get_reg(machine, a), get_reg(machine, b)))
  end

  def bani(machine, a, b, c) do
    set_reg(machine, c, band(get_reg(machine, a), b))
  end

  def borr(machine, a, b, c) do
    set_reg(machine, c, bor(get_reg(machine, a), get_reg(machine, b)))
  end

  def bori(machine, a, b, c) do
    set_reg(machine, c, bor(get_reg(machine, a), b))
  end

  @doc """

  ## Examples

      iex> Day16.setr(Day16.new_machine([3, 2, 7, 5]), 1, 0, 2) |> Day16.registers()
      [3, 2, 2, 5]

      iex> Day16.setr(Day16.new_machine([1, 2, 3, 6]), 2, 3, 0) |> Day16.registers()
      [3, 2, 3, 6]

  """
  def setr(machine, a, _b, c) do
    set_reg(machine, c, get_reg(machine, a))
  end

  @doc """

  ## Examples

      iex> Day16.seti(Day16.new_machine([3, 2, 7, 5]), 1, 0, 2) |> Day16.registers()
      [3, 2, 1, 5]

      iex> Day16.seti(Day16.new_machine([1, 2, 3, 6]), 2, 3, 0) |> Day16.registers()
      [2, 2, 3, 6]

  """
  def seti(machine, a, _b, c) do
    set_reg(machine, c, a)
  end

  def gtir(machine, a, b, c) do
    set_reg(machine, c, if(a > get_reg(machine, b), do: 1, else: 0))
  end

  def gtri(machine, a, b, c) do
    set_reg(machine, c, if(get_reg(machine, a) > b, do: 1, else: 0))
  end

  def gtrr(machine, a, b, c) do
    set_reg(machine, c, if(get_reg(machine, a) > get_reg(machine, b), do: 1, else: 0))
  end

  def eqir(machine, a, b, c) do
    set_reg(machine, c, if(a == get_reg(machine, b), do: 1, else: 0))
  end

  def eqri(machine, a, b, c) do
    set_reg(machine, c, if(get_reg(machine, a) == b, do: 1, else: 0))
  end

  def eqrr(machine, a, b, c) do
    set_reg(machine, c, if(get_reg(machine, a) == get_reg(machine, b), do: 1, else: 0))
  end

  def parse_input(input) do
    [trace, program] = String.split(input, ~r/\n\n\n+/)
    %{trace: parse_trace(trace), program: parse_program(program)}
  end

  def parse_trace(input) do
    String.split(input, ~r/\n\n+/, trim: true)
    |> Enum.map(fn str ->
      {:ok, [element | []], _, _, _, _} = trace_element_parser(str)
      element
    end)
  end

  trace_register =
    ignore(string("["))
    |> times(concat(integer(min: 1), ignore(string(", "))), 3)
    |> integer(min: 1)
    |> ignore(string("]"))
    |> wrap()

  operation =
    integer(min: 1)
    |> ignore(string(" "))
    |> integer(min: 1)
    |> ignore(string(" "))
    |> integer(min: 1)
    |> ignore(string(" "))
    |> integer(min: 1)
    |> wrap()
    |> map({List, :to_tuple, []})

  defparsec(
    :trace_element_parser,
    ignore(string("Before: "))
    |> concat(trace_register)
    |> ignore(string("\n"))
    |> concat(operation)
    |> ignore(string("\nAfter:  "))
    |> concat(trace_register)
    |> wrap()
    |> map({List, :to_tuple, []})
  )

  defparsec(
    :program_parser,
    operation
    |> concat(ignore(string("\n")))
    |> repeat()
  )

  def parse_program(input) do
    {:ok, program, _, _, _, _} = program_parser(input)
    program
  end

  defp instructions() do
    %{
      addr: &addr/4,
      addi: &addi/4,
      mulr: &mulr/4,
      muli: &muli/4,
      banr: &banr/4,
      bani: &bani/4,
      borr: &borr/4,
      bori: &bori/4,
      setr: &setr/4,
      seti: &seti/4,
      gtir: &gtir/4,
      gtri: &gtri/4,
      gtrr: &gtrr/4,
      eqir: &eqir/4,
      eqri: &eqri/4,
      eqrr: &eqrr/4
    }
  end

  def test_trace({before, {_code, a, b, c}, expected}) do
    Enum.reduce(instructions(), [], fn {key, func}, acc ->
      result = func.(new_machine(before), a, b, c)

      if registers(result) == expected do
        [key | acc]
      else
        acc
      end
    end)
  end

  def decifer_codes(traces) do
    potential_codes =
      Stream.map(traces, fn {_before, {code, _a, _b, _c}, _expected} = trace_element ->
        {code, MapSet.new(Day16.test_trace(trace_element))}
      end)
      |> Enum.reduce(%{}, fn {code, new_ops}, acc ->
        Map.update(acc, code, new_ops, fn ops ->
          MapSet.intersection(ops, new_ops)
        end)
      end)

    decifer_codes(%{}, potential_codes)
  end

  def decifer_codes(known_codes, %{} = potential) when map_size(potential) == 0 do
    known_codes
  end

  def decifer_codes(known_codes, potential_codes) do
    new_known_codes =
      Enum.filter(potential_codes, fn {_code, ops} ->
        MapSet.size(ops) == 1
      end)
      |> Enum.map(fn {code, ops} -> {code, MapSet.to_list(ops) |> List.first()} end)
      |> Map.new()

    ops_to_remove = Map.values(new_known_codes) |> MapSet.new()

    potential_codes =
      Map.drop(potential_codes, Map.keys(new_known_codes))
      |> Enum.reduce(%{}, fn {code, ops}, acc ->
        Map.put(acc, code, MapSet.difference(ops, ops_to_remove))
      end)

    known_codes = Map.merge(known_codes, new_known_codes)

    decifer_codes(known_codes, potential_codes)
  end

  def run_program(traces, program) do
    code_map = decifer_codes(traces)

    instrs = instructions()

    Enum.reduce(program, Day16.new_machine(), fn {code, a, b, c}, machine ->
      instrs[code_map[code]].(machine, a, b, c)
    end)
    |> registers()
  end
end
