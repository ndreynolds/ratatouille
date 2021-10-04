defmodule Ratatouille.Renderer.Border do
  @moduledoc """
  Primitives for rendering borders
  """

  alias Ratatouille.Renderer.{Box, Canvas, Line, Text}

  @borders %{
    top: "─",
    top_right: "┐",
    right: "│",
    bottom_right: "┘",
    bottom: "─",
    bottom_left: "└",
    left: "│",
    top_left: "┌"
  }

  def render(%Canvas{render_box: box} = canvas, attrs) do
    width = Box.width(box)
    height = Box.height(box)

    canvas
    |> Line.render_horizontal(Box.top_left(box), @borders.top, width, attrs)
    |> Line.render_horizontal(Box.bottom_left(box), @borders.bottom, width, attrs)
    |> Line.render_vertical(Box.top_left(box), @borders.left, height, attrs)
    |> Line.render_vertical(Box.top_right(box), @borders.right, height, attrs)
    |> Text.render(Box.top_left(box), @borders.top_left, attrs)
    |> Text.render(Box.top_right(box), @borders.top_right, attrs)
    |> Text.render(Box.bottom_left(box), @borders.bottom_left, attrs)
    |> Text.render(Box.bottom_right(box), @borders.bottom_right, attrs)
  end
end
