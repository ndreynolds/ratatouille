defmodule ExTermbox.Renderer.Table do
  @moduledoc false

  # Minimum padding on the right of each column
  @min_padding 2

  alias ExTermbox.Position
  alias ExTermbox.Renderer.{Box, Canvas, Element, Text}

  def render(%Canvas{} = canvas, rows) do
    canvas
    |> Canvas.padded(1)
    |> render_table(rows)
    |> Canvas.padded(-1)
    |> Canvas.consume(0, 1)
  end

  defp render_table(%Canvas{} = canvas, rows) do
    col_sizes = column_sizes(canvas.box, rows)
    max_rows = Box.height(canvas.box)

    rows
    |> Enum.take(max_rows)
    |> Enum.reduce(canvas, fn row, canvas ->
      {new_canvas, _offset} = render_table_row(canvas, col_sizes, row)
      Canvas.consume(new_canvas, 0, 1)
    end)
  end

  defp render_table_row(%Canvas{} = canvas, col_sizes, row) do
    cells = row.attributes[:values] || []

    cells
    |> Enum.zip(col_sizes)
    |> Enum.reduce({canvas, 0}, &render_table_cell(&1, &2, row.attributes))
  end

  defp render_table_cell({text, col_size}, {canvas, offset}, attrs) do
    pos = Position.translate_x(canvas.box.top_left, offset)
    canvas = Text.render(canvas, pos, text, attrs)

    {canvas, offset + col_size}
  end

  defp column_sizes(%Box{} = box, rows) do
    rows = for %Element{attributes: %{values: values}} <- rows, do: values
    :ok = check_row_uniformity(rows)

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

  defp padded_columns(column_sizes, max_size) do
    rem_space = max_size - Enum.sum(column_sizes)

    per_column_padding =
      case length(column_sizes) do
        0 -> 0
        n -> Integer.floor_div(rem_space, n)
      end

    Enum.map(column_sizes, &(&1 + per_column_padding))
  end

  defp transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp check_row_uniformity([]) do
    :ok
  end

  defp check_row_uniformity(rows) do
    num_columns = length(hd(rows))

    if Enum.all?(rows, &(length(&1) == num_columns)) do
      :ok
    else
      {:error, "All rows must have the same number of columns"}
    end
  end
end
