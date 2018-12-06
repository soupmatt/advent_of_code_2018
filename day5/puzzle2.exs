file = File.read!('input.txt') |> String.trim()
collapsed = Enum.reduce(?a..?z, Map.new(), fn char, acc ->
  stripped_file = Day5.strip_char(file, char)
  Map.put(acc, [char], Day5.collapse_string(stripped_file) |> String.length())
end)
IO.inspect Enum.min_by(collapsed, fn {_, len} -> len end)
