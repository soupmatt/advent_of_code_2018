# heavily inspired by https://github.com/sasa1977/aoc/blob/823e7d212a4fce2e795ae49322976aaab200376d/lib/2018/day14.ex
defmodule Day14 do

  @doc """
  Hello world.

  ## Examples

      iex> Day14.recipes() |> Enum.take(2)
      [3, 7]

      iex> Day14.recipes() |> Enum.take(4)
      [3, 7, 1, 0]

      iex> Day14.recipes() |> Enum.take(6)
      [3, 7, 1, 0, 1, 0]

      iex> Day14.recipes() |> Enum.take(20)
      [3, 7, 1, 0, 1, 0, 1, 2, 4, 5, 1, 5, 8, 9, 1, 6, 7, 7, 9, 2]

  """
  def recipes() do
    Stream.resource(&initial_state/0, &next_recipies/1, &destroy_state/1)
  end

  @doc """

  ## Examples

      iex> Day14.find_sublist("51589")
      9

      iex> Day14.find_sublist("01245")
      5

      iex> Day14.find_sublist("92510")
      18

      iex> Day14.find_sublist("59414")
      2018

  """
  def find_sublist(sublist) do
    target_recipes = sublist |> to_charlist() |> Enum.map(&(&1 - ?0))
    Enum.reduce_while(recipes(), {target_recipes, target_recipes, 0}, fn el, {search, targets, index} ->
      result = case {el, {search, targets, index}} do
        {el, {[el], targets, index}} -> {:halt, index + 1 - length(targets)}
        {el, {[el | rest], targets, index}} -> {:cont, {rest, targets, index+1}}
        {el, {_, [el | rest] = targets, index}} -> {:cont, {rest, targets, index+1}}
        {_el, {_, targets, index}} -> {:cont, {targets, targets, index+1}}
      end
      result
    end)
  end

  defp initial_state() do
    initial_recipes = [3, 7]
    recipes = :ets.new(:recipes, [:set, :private, read_concurrency: true, write_concurrency: true])
    add_recipes(recipes, initial_recipes)
    {0, 1, recipes, initial_recipes}
  end

  defp next_recipies({elf1_pos, elf2_pos, recipes, previous_new_recipes}) do
    elf1_recipe = recipe_at(recipes, elf1_pos)
    elf2_recipe = recipe_at(recipes, elf2_pos)

    new_recipe = elf1_recipe + elf2_recipe
    new_recipes = if new_recipe < 10 do
      [new_recipe]
    else
      [1, new_recipe-10]
    end

    add_recipes(recipes, new_recipes)
    table_size = num_recipes(recipes)

    elf1_new_pos = rem(elf1_pos + 1 + elf1_recipe, table_size)
    elf2_new_pos = rem(elf2_pos + 1 + elf2_recipe, table_size)

    {previous_new_recipes, {elf1_new_pos, elf2_new_pos, recipes, new_recipes}}
  end

  defp destroy_state({_elf1_pos, _elf2_pos, recipes, _new_recipes}) do
    :ets.delete(recipes)
  end

  defp add_recipes(recipes, new_recipes) do
    new_recipes
    |> Stream.with_index(num_recipes(recipes))
    |> Enum.each(fn {recipe, index} -> :ets.insert(recipes, {index, recipe}) end)
  end

  defp recipe_at(recipes, position) do
    [{^position, recipe}] = :ets.lookup(recipes, position)
    recipe
  end

  defp num_recipes(recipes), do: :ets.info(recipes, :size)
end
