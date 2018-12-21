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
    [trace, _program] = String.split(input, ~r/\n\n\n+/)
    %{trace: parse_trace(trace), program: nil}
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
end
