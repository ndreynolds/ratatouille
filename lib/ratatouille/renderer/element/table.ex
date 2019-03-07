defmodule Ratatouille.Renderer.Element.Table do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  # Minimum padding on the right of each column
  @min_padding 2

  alias ExTermbox.Position
  alias Ratatouille.Renderer.{Box, Canvas, Element, Text}

  @impl true
  def render(%Canvas{} = canvas, %Element{children: rows}, _render_fn) do
    canvas
    |> render_table(rows)
    |> Canvas.consume(0, 1)
  end

  defp render_table(%Canvas{} = canvas, rows) do
    col_sizes = column_sizes(canvas.render_box, rows)
    max_rows = Box.height(canvas.render_box)

    rows
    |> Enum.take(max_rows)
    |> Enum.reduce(canvas, fn row, canvas ->
      {new_canvas, _offset} = render_table_row(canvas, row, col_sizes)
      Canvas.consume(new_canvas, 0, 1)
    end)
  end

  defp render_table_row(%Canvas{} = canvas, row, col_sizes) do
    row.children
    |> Enum.zip(col_sizes)
    |> Enum.reduce({canvas, 0}, fn {cell, col_size}, {acc_canvas, offset} ->
      new_cell = %Element{
        cell
        | attributes: Map.merge(row.attributes, cell.attributes)
      }

      render_table_cell(acc_canvas, new_cell, col_size, offset)
    end)
  end

  defp render_table_cell(%Canvas{} = canvas, cell, col_size, offset)
       when col_size > 0 do
    text = cell.attributes[:content] || ""
    pos = Position.translate_x(canvas.render_box.top_left, offset)
    padded_text = String.pad_trailing(text, col_size, " ")

    new_canvas = Text.render(canvas, pos, padded_text, cell.attributes)

    {new_canvas, offset + col_size}
  end

  defp render_table_cell(canvas, _cell, _col_size, offset) do
    {canvas, offset}
  end

  defp column_sizes(%Box{} = box, rows) do
    cells_by_row =
      for row <- rows do
        for cell <- row.children, do: cell.attributes[:content] || ""
      end

    :ok = check_row_uniformity(cells_by_row)

    max_width = Box.width(box)
    columns = transpose(cells_by_row)

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
          size_excluded = Enum.sum(sizes)
          size_included = size_excluded + size

          if size_included <= max_size,
            do: {:open, sizes ++ [size]},
            else: {:full, sizes ++ [max_size - size_excluded]}
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
