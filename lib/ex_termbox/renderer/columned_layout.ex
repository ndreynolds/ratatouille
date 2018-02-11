defmodule ExTermbox.Renderer.ColumnedLayout do
  @moduledoc """
  Renders a layout with one or more columns.
  """

  alias ExTermbox.Position
  alias ExTermbox.Renderer.{Box, Canvas}

  def render(%Canvas{box: box} = canvas, children, render_fun) do
    {new_canvas, boxes} =
      children
      |> Enum.zip(column_boxes(box, length(children)))
      |> Enum.reduce({canvas, []}, &reduce_columns(render_fun, &1, &2))

    consume_y = largest_y(boxes) - box.top_left.y

    %Canvas{new_canvas | box: box}
    |> Canvas.consume(0, consume_y)
  end

  defp largest_y(boxes) do
    boxes
    |> Enum.map(fn box -> box.top_left.y end)
    |> Enum.max()
  end

  defp reduce_columns(render_fun, {el, column_box}, {canvas, boxes}) do
    column_canvas = %Canvas{canvas | box: column_box}
    canvas = render_fun.(column_canvas, el)
    {canvas, [canvas.box | boxes]}
  end

  defp column_boxes(outer_box, num_columns) do
    col_width = Integer.floor_div(Box.width(outer_box), num_columns)

    0..num_columns
    |> Enum.map(&column_box(outer_box, col_width, &1))
  end

  defp column_box(outer_box, col_width, col_idx) do
    Box.from_dimensions(
      col_width,
      Box.height(outer_box),
      Position.translate_x(outer_box.top_left, col_width * col_idx)
    )
  end
end
