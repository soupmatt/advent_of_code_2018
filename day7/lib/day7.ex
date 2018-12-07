defmodule Day7 do
  import NimbleParsec

  @doc """

  ## Examples

      iex> Day7.parse_instruction_record("Step L must be finished before step V can begin.")
      {?L, ?V}

      iex> Day7.parse_instruction_record("Step J must be finished before step B can begin.")
      {?J, ?B}

  """
  def parse_instruction_record(record) do
    {:ok, [a, b | []], _, _, _, _} = parse_instruction(record)
    {a, b}
  end

  defparsecp(
    :parse_instruction,
    ignore(string("Step "))
    |> ascii_char([?A..?Z])
    |> ignore(string(" must be finished before step "))
    |> ascii_char([?A..?Z])
    |> ignore(string(" can begin."))
  )

  @doc """

  ## Examples

      iex> Day7.assemble_sleigh([
      ...> "Step C must be finished before step A can begin.",
      ...> "Step C must be finished before step F can begin.",
      ...> "Step A must be finished before step B can begin.",
      ...> "Step A must be finished before step D can begin.",
      ...> "Step B must be finished before step E can begin.",
      ...> "Step D must be finished before step E can begin.",
      ...> "Step F must be finished before step E can begin.",
      ...> ])
      "CABDFE"

  """
  def assemble_sleigh(instruction_records) do
    instructions = Enum.map(instruction_records, &parse_instruction_record/1)

    graph = Graph.new(type: :directed) |> Graph.add_edges(instructions)

    queue = add_roots_to_queue(Graph.vertices(graph), PriorityQueue.new(), graph)
    assemble_sleigh(graph, PriorityQueue.pop(queue), [])
  end

  defp assemble_sleigh(graph, {{:value, next_vertex}, queue}, acc) do
    dependents = Graph.out_neighbors(graph, next_vertex)
    graph = Graph.delete_vertex(graph, next_vertex)

    queue = add_roots_to_queue(dependents, queue, graph)

    assemble_sleigh(graph, PriorityQueue.pop(queue), [next_vertex | acc])
  end

  defp assemble_sleigh(_graph, {:empty, _queue}, acc) do
    Enum.reverse(acc) |> to_string()
  end

  defp add_roots_to_queue(candidates, queue, graph) do
    Enum.filter(candidates, fn vert -> Graph.in_degree(graph, vert) == 0 end)
    |> Enum.reduce(queue, fn vert, q -> PriorityQueue.push(q, vert, vert) end)
  end
end
