defmodule Ratatouille.Renderer.Element.View do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias Ratatouille.Renderer.{Box, Canvas, Element}

  alias ExTermbox.Position

  @impl true
  def render(canvas, %Element{attributes: attrs, children: children}, render_fn) do
    canvas
    |> render_top_bar(attrs[:top_bar], render_fn)
    |> render_fn.(children)
    |> render_bottom_bar(attrs[:bottom_bar], render_fn)
  end

  defp render_top_bar(canvas, nil, _render_fn), do: canvas

  defp render_top_bar(%Canvas{render_box: box} = canvas, bar, render_fn) do
    canvas
    |> Canvas.put_box(Box.head(box, 1))
    |> render_fn.(bar)
    |> Canvas.put_box(box)
    |> Canvas.consume_rows(1)
  end

  defp render_bottom_bar(canvas, nil, _render_fn), do: canvas

  defp render_bottom_bar(%Canvas{render_box: box} = canvas, bar, render_fn) do
    new_box = %Box{
      top_left: box.top_left,
      bottom_right: Position.translate_y(box.bottom_right, -1)
    }

    canvas
    |> Canvas.put_box(Box.tail(box, 1))
    |> render_fn.(bar)
    |> Canvas.put_box(new_box)
  end
end
