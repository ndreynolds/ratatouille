defmodule Ratatouille.Renderer.Element.Row do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias Ratatouille.Renderer.{Box, Canvas, Element}

  @grid_size 12

  @impl true
  def render(
        %Canvas{render_box: box} = canvas,
        %Element{children: children},
        render_fun
      ) do
    col_sizes =
      Enum.map(children, fn
        %Element{attributes: %{size: size}} -> size
        _ -> 0
      end)

    {new_canvas, boxes} =
      children
      |> Enum.zip(column_boxes(box, col_sizes))
      |> Enum.reduce({canvas, []}, &reduce_columns(render_fun, &1, &2))

    occupied_rows = largest_y(boxes) - box.top_left.y

    new_canvas
    |> Canvas.put_box(box)
    |> Canvas.consume_rows(occupied_rows)
  end

  defp largest_y(boxes) do
    boxes
    |> Enum.map(fn box -> box.top_left.y end)
    |> Enum.max(fn -> 0 end)
  end

  defp reduce_columns(render_fun, {el, column_box}, {canvas, boxes}) do
    column_canvas = %Canvas{canvas | render_box: column_box}
    canvas = render_fun.(column_canvas, el)
    {canvas, [canvas.render_box | boxes]}
  end

  defp column_boxes(outer_box, col_sizes) do
    col_count = length(col_sizes)

    outer_box_width = Box.width(outer_box)
    unit_width = outer_box_width / @grid_size
    total_width = Enum.sum(for size <- col_sizes, do: trunc(unit_width * size))

    padding =
      if col_count > 1 do
        trunc((outer_box_width - total_width) / (col_count - 1))
      else
        0
      end

    {boxes, _remaining_box} =
      Enum.map_reduce(col_sizes, outer_box, fn size, remaining_box ->
        col_width = trunc(size * unit_width)
        col_box = column_box(remaining_box, col_width)
        remaining_box = Box.translate(col_box, col_width + padding, 0)
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
