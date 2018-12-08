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

  @doc """

  ## Examples

      iex> Day7.step_time(?A, 0)
      1

      iex> Day7.step_time(?J, 0)
      10

      iex> Day7.step_time(?Z, 0)
      26

      iex> Day7.step_time(?A, 3)
      4

      iex> Day7.step_time(?J, 17)
      27

      iex> Day7.step_time(?Z, 60)
      86

  """
  def step_time(step, additional_seconds) when step >= ?A and step <= ?Z and additional_seconds >= 0 do
    step - 64 + additional_seconds
  end

  @doc """

  ## Examples

      iex> Day7.assemble_sleigh_timed([
      ...> "Step C must be finished before step A can begin.",
      ...> "Step C must be finished before step F can begin.",
      ...> "Step A must be finished before step B can begin.",
      ...> "Step A must be finished before step D can begin.",
      ...> "Step B must be finished before step E can begin.",
      ...> "Step D must be finished before step E can begin.",
      ...> "Step F must be finished before step E can begin.",
      ...> ], 2, 0)
      {"CABFDE", 15}

      iex> Day7.assemble_sleigh_timed([
      ...> "Step C must be finished before step A can begin.",
      ...> "Step C must be finished before step F can begin.",
      ...> "Step A must be finished before step B can begin.",
      ...> "Step A must be finished before step D can begin.",
      ...> "Step B must be finished before step E can begin.",
      ...> "Step D must be finished before step E can begin.",
      ...> "Step F must be finished before step E can begin.",
      ...> ], 3, 1)
      {"CABFDE", 17}

  """
  @spec assemble_sleigh_timed([String.t], pos_integer, non_neg_integer) :: {String.t, non_neg_integer}
  def assemble_sleigh_timed(instruction_records, worker_count, additional_seconds) do
    instructions = Enum.map(instruction_records, &parse_instruction_record/1)

    graph = Graph.new(type: :directed) |> Graph.add_edges(instructions)

    queue = add_roots_to_queue(Graph.vertices(graph), PriorityQueue.new(), graph)

    step_time_func = fn step -> step_time(step, additional_seconds) end

    assemble_sleigh_timed(graph, List.duplicate({:idle, nil, nil}, worker_count), queue, [], step_time_func, 0)
  end

  defp assemble_sleigh_timed(graph, workers, queue, finished_nodes, step_time_func, ticks) do
    {graph, workers, queue, finished_nodes} = Enum.reduce(Enum.reverse(workers), {graph, [], queue, finished_nodes}, fn
      {:idle, _, _}, {graph, workers, queue, finished_nodes} ->
        {queue, worker} = worker_from_queue(queue, step_time_func)
        {graph, [worker | workers], queue, finished_nodes}
      {:busy, step, 1}, {graph, workers, queue, finished_nodes} ->
        {graph, queue} = finish_vertex(step, graph, queue)
        {queue, worker} = worker_from_queue(queue, step_time_func)
        {graph, [worker | workers], queue, [step | finished_nodes]}
      {:busy, step, remaining}, {graph, workers, queue, finished_nodes} ->
        {graph, [{:busy, step, remaining-1} | workers], queue, finished_nodes}
    end)
    # IO.puts "#{ticks}, #{Enum.map(workers, fn {_, step, _} -> [step] end) |> inspect()} #{to_string(finished_nodes)}"
    if Enum.all?(workers, &match?({:idle, _, _}, &1)) do
      {Enum.reverse(finished_nodes) |> to_string(), ticks}
    else
      assemble_sleigh_timed(graph, workers, queue, finished_nodes, step_time_func, ticks+1)
    end
  end

  defp worker_from_queue(queue, step_time_func) do
    case PriorityQueue.pop(queue) do
      {{:value, next_vertex}, queue} ->
        {queue, {:busy, next_vertex, step_time_func.(next_vertex)}}
      {:empty, queue} ->
        {queue, {:idle, nil, nil}}
    end
  end

  defp finish_vertex(vertex, graph, queue) do
    dependents = Graph.out_neighbors(graph, vertex)
    graph = Graph.delete_vertex(graph, vertex)
    queue = add_roots_to_queue(dependents, queue, graph)
    {graph, queue}
  end
end
