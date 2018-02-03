defmodule ExTermbox.Renderer.Border do
  @moduledoc """
  Primitives for rendering borders
  """

  alias ExTermbox.Renderer.{Box, Canvas, Line, Text}

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

  def render(%Canvas{box: box} = canvas) do
    width = Box.width(box)
    height = Box.height(box)

    canvas
    |> Line.render_horizontal(Box.top_left(box), @borders.top, width)
    |> Line.render_horizontal(Box.bottom_left(box), @borders.bottom, width)
    |> Line.render_vertical(Box.top_left(box), @borders.left, height)
    |> Line.render_vertical(Box.top_right(box), @borders.right, height)
    |> Text.render(Box.top_left(box), @borders.top_left)
    |> Text.render(Box.top_right(box), @borders.top_right)
    |> Text.render(Box.bottom_left(box), @borders.bottom_left)
    |> Text.render(Box.bottom_right(box), @borders.bottom_right)
  end
end
