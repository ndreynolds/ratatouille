defmodule ExTermbox.Renderer.Table do
  @moduledoc false

  # Minimum padding on the right of each column
  @min_padding 2

  alias ExTermbox.Position
  alias ExTermbox.Renderer.{Box, Canvas, Text}

  def render(%Canvas{} = canvas, rows) do
    canvas
    |> Canvas.padded(1)
    |> render_table(rows)
    |> Canvas.padded(-1)
    |> Canvas.translate(0, 1)
  end

  defp render_table(%Canvas{} = canvas, rows) do
    col_sizes = column_sizes(canvas.box, rows)
    # TODO: scrollable?
    max_rows = Box.height(canvas.box)

    rows
    |> Enum.take(max_rows)
    |> Enum.map(&Enum.zip(&1, col_sizes))
    |> Enum.reduce(canvas, fn row, canvas ->
      {new_canvas, _offset} = render_table_row(canvas, row)
      %Canvas{new_canvas | box: Box.translate(canvas.box, 0, 1)}
    end)
  end

  defp render_table_row(%Canvas{} = canvas, row) do
    row
    |> Enum.reduce({canvas, 0}, &render_table_cell(&1, &2))
  end

  defp render_table_cell({text, size}, {canvas, offset}) do
    canvas =
      Text.render(
        canvas,
        Position.translate_x(canvas.box.top_left, offset),
        text
      )

    {canvas, offset + size}
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
      |> Enum.map(&String.length/1)
      |> Enum.max()
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
