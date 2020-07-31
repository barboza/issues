defmodule Issues.Printer do
  @spec print([map()], list(String.t())) :: :ok
  def print(issues, columns) do
    with issues = issues |> filter_and_convert_to_string(columns),
         columns = calculate_columns(issues, columns) do
      print_headers(columns)
      Enum.each(issues, &print_row(&1, columns))
      print_line(columns)
    end
  end

  def calculate_columns(issues, columns) do
    columns
    |> Enum.reduce([], fn column, acc ->
      [{column, get_max_size(column, issues)} | acc]
    end)
    |> Enum.reverse()
  end

  def print_headers(columns) do
    print_line(columns)

    columns
    |> Enum.reduce("|", fn {column, size}, acc ->
      column =
        case column do
          "number" -> "#"
          column -> column
        end

      acc <> pad(column, size) <> "|"
    end)
    |> IO.puts()

    print_line(columns)
  end

  def print_row(issue, columns) do
    row =
      columns
      |> Enum.reduce("|", fn {column, size}, acc ->
        acc <> pad(issue[column], size) <> "|"
      end)

    IO.puts(row)
  end

  def print_line(columns) do
    line =
      columns
      |> Enum.reduce("+", fn {_, size}, acc ->
        acc <> String.duplicate("-", size) <> "+"
      end)

    IO.puts(line)
  end

  def pad(string, size) do
    string = parse_as_string(string)
    length = String.length(string)

    offset =
      (size - length)
      |> remove_negatives()

    string <> String.duplicate(" ", offset)
  end

  def filter_and_convert_to_string(issues, columns) do
    issues
    |> Enum.map(fn issue ->
      issue
      |> Enum.filter(fn {k, _} -> Enum.member?(columns, k) end)
      |> Enum.map(fn {k, v} -> {k, parse_as_string(v)} end)
      |> Map.new()
    end)
  end

  defp remove_negatives(n) when n < 0, do: 0
  defp remove_negatives(n), do: n

  defp parse_as_string(n) when is_integer(n), do: Integer.to_string(n)
  defp parse_as_string(string), do: string

  defp get_max_size(column, issues) do
    issues
    |> Enum.map(&Map.get(&1, column))
    |> List.insert_at(0, column)
    |> get_max_size()
  end

  defp get_max_size(values) do
    values
    |> Enum.max_by(&String.length/1)
    |> String.length()
  end
end
