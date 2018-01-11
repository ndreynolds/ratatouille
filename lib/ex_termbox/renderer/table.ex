defmodule ExTermbox.Renderer.Table do
  # Minimum padding on the right of each column
  @min_padding 2

  alias ExTermbox.Position
  alias ExTermbox.Renderer.{Box, Utils}

  def render(%Box{} = box, rows) do
    col_sizes = column_sizes(box, rows)

    rows
    |> Enum.map(&Enum.zip(&1, col_sizes))
    |> Enum.reduce(box, fn row, box ->
      render_table_row(box, row)
      Box.translate(box, 0, 1)
    end)
  end

  defp render_table_row(box, row) do
    row |> Enum.reduce(0, &render_table_cell(box, &1, &2))
  end

  defp render_table_cell(box, {text, size}, offset) do
    Utils.render_text(
      Position.translate_x(box.top_left, offset),
      text
    )

    offset + size
  end

  defp column_sizes(%Box{} = box, rows) do
    check_row_uniformity!(rows)

    max_width = Box.width(box)
    columns = transpose(rows)

    columns
    |> min_column_sizes()
    |> displayable_columns(max_width)
    |> padded_columns(max_width)
  end

  defp min_column_sizes(columns) do
    Enum.map(columns, fn col ->
      col
      |> Enum.max_by(&String.length/1)
      |> String.length()
      |> Kernel.+(@min_padding)
    end)
  end

  defp displayable_columns(min_column_sizes, max_size) do
    {_, displayable_columns} =
      Enum.reduce(min_column_sizes, {:open, []}, fn
        _size, {:full, _} = acc ->
          acc

        size, {:open, sizes} ->
          if Enum.sum([size | sizes]) < max_size,
            do: {:open, sizes ++ [size]},
            else: {:full, sizes}
      end)

    if Enum.empty?(displayable_columns),
      do: Enum.take(min_column_sizes, 1),
      else: displayable_columns
  end

  def padded_columns(column_sizes, max_size) do
    rem_space = max_size - Enum.sum(column_sizes)
    per_column_padding = Integer.floor_div(rem_space, length(column_sizes))
    Enum.map(column_sizes, &(&1 + per_column_padding))
  end

  defp transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp check_row_uniformity!(rows) do
    num_columns = length(hd(rows))

    unless Enum.all?(rows, &(length(&1) == num_columns)),
      do: raise("All rows must have the same number of columns")
  end
end
