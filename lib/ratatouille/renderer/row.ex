defmodule Ratatouille.Renderer.Row do
  @moduledoc """
  Renders a layout with one or more columns.
  """

  alias Ratatouille.Renderer.{Box, Canvas, Element}

  @grid_size 12

  def render(%Canvas{box: box} = canvas, children, render_fun) do
    col_sizes =
      Enum.map(children, fn
        %Element{attributes: %{size: size}} -> size
        _ -> 0
      end)

    {new_canvas, boxes} =
      children
      |> Enum.zip(column_boxes(box, col_sizes))
      |> Enum.reduce({canvas, []}, &reduce_columns(render_fun, &1, &2))

    consume_y = largest_y(boxes) - box.top_left.y

    %Canvas{new_canvas | box: box}
    |> Canvas.consume(0, consume_y)
  end

  defp largest_y(boxes) do
    boxes
    |> Enum.map(fn box -> box.top_left.y end)
    |> Enum.max(fn -> 0 end)
  end

  defp reduce_columns(render_fun, {el, column_box}, {canvas, boxes}) do
    column_canvas = %Canvas{canvas | box: column_box}
    canvas = render_fun.(column_canvas, el)
    {canvas, [canvas.box | boxes]}
  end

  defp column_boxes(outer_box, col_sizes) do
    unit_width = Box.width(outer_box) / @grid_size

    {boxes, _remaining_box} =
      Enum.map_reduce(col_sizes, outer_box, fn size, remaining_box ->
        col_width = trunc(size * unit_width)
        col_box = column_box(remaining_box, col_width)
        remaining_box = Box.translate(col_box, col_width, 0)
        {col_box, remaining_box}
      end)

    boxes
  end

  defp column_box(outer_box, col_width) do
    Box.from_dimensions(
      col_width,
      Box.height(outer_box),
      outer_box.top_left
    )
  end
end
