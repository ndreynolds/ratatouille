defmodule Ratatouille.Renderer.Element.Canvas do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias ExTermbox.{Cell, Position}

  alias Ratatouille.Renderer.{Canvas, Cells, Element}

  @impl true
  def render(
        %Canvas{} = canvas,
        %Element{
          children: children,
          attributes: %{height: height, width: width}
        },
        _render_fn
      ) do
    cells =
      for %Element{tag: :canvas_cell, attributes: %{x: x, y: y} = attrs} <-
            children,
          x < width,
          y < height do
        %Cell{
          bg: Cells.background(attrs),
          fg: Cells.foreground(attrs),
          ch: to_char(attrs[:char]),
          position: %Position{
            x: attrs[:x] + canvas.render_box.top_left.x,
            y: attrs[:y] + canvas.render_box.top_left.y
          }
        }
      end

    canvas
    |> Canvas.merge_cells(cells)
    |> Canvas.consume_rows(height)
  end

  defp to_char(nil), do: nil
  defp to_char(ch) when is_integer(ch), do: ch
  defp to_char(<<ch::utf8>>), do: ch
end
