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

  defp sum_metadata({child_count, metadata_count, child_nodes, metadata}, acc) do
    acc = acc + Enum.sum(metadata)
    Enum.reduce(child_nodes, acc, &sum_metadata/2)
  end
end
