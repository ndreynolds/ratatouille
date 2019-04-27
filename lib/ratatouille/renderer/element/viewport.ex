defmodule Ratatouille.Renderer.Element.Viewport do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias Ratatouille.Renderer.{Box, Canvas, Element}

  alias ExTermbox.{Cell, Position}

  @impl true
  def render(
        %Canvas{render_box: box} = original_canvas,
        %Element{attributes: attrs, children: children},
        render_fn
      ) do
    dx = attrs[:offset_x] || 0
    dy = attrs[:offset_y] || 0

    stretched_box = translate_bottom_right(box, dx, dy)

    rendered_canvas =
      render_fn.(
        %Canvas{original_canvas | render_box: stretched_box, cells: %{}},
        children
      )

    adjusted_box = translate_bottom_right(rendered_canvas.render_box, -dx, -dy)

    %Canvas{
      merge_cells(original_canvas, rendered_canvas.cells, -dx, -dy)
      | render_box: adjusted_box
    }
  end

  defp translate_bottom_right(box, dx, dy) do
    %Box{box | bottom_right: Position.translate(box.bottom_right, dx, dy)}
  end

  defp merge_cells(%Canvas{render_box: box} = canvas, cells, dx, dy) do
    %Position{x: x0, y: y0} = box.top_left

    new_cells =
      for {%Position{x: x, y: y}, cell} <- cells,
          x + dx >= x0,
          y + dy >= y0,
          into: %{} do
        offset_pos = %Position{x: x + dx, y: y + dy}
        {offset_pos, %Cell{cell | position: offset_pos}}
      end

    %Canvas{canvas | cells: Map.merge(canvas.cells, new_cells)}
  end
end
