defmodule Day8 do
  @doc """
  Construct a tree from the entries
  """
  def construct_tree(entries) do
    {node, _} = build_node(entries)
    node
  end

  defp build_node([child_count, metadata_count | remaining]) do
    {child_nodes, remaining} = build_child_nodes([], remaining, child_count)
    {metadata, remaining} = Enum.split(remaining, metadata_count)
    {{child_count, metadata_count, child_nodes, metadata}, remaining}
  end

  defp build_child_nodes(nodes, remaining, 0) do
    {Enum.reverse(nodes), remaining}
  end

  defp build_child_nodes(nodes, remaining, count) do
    {new_node, remaining} = build_node(remaining)
    build_child_nodes([new_node | nodes], remaining, count - 1)
  end

  def sum_metadata(tree) do
    sum_metadata(tree, 0)
  end

  defp sum_metadata({_, _, child_nodes, metadata}, acc) do
    acc = acc + Enum.sum(metadata)
    Enum.reduce(child_nodes, acc, &sum_metadata/2)
  end

  def node_value(node) do
    node_value(node, 0)
  end

  defp node_value({0, _, _, metadata}, acc) do
    acc + Enum.sum(metadata)
  end

  defp node_value({child_count, _, child_nodes, metadata}, acc) do
    Enum.reduce(metadata, acc, fn data_value, acc ->
      acc + child_node_value(child_nodes, child_count, data_value)
    end)
  end

  defp child_node_value(_, _, 0) do
    0
  end

  defp child_node_value(_, child_count, index) when index > child_count do
    0
  end

  defp child_node_value(child_nodes, child_count, index) when index <= child_count do
    Enum.at(child_nodes, index - 1)
    |> node_value(0)
  end
end
