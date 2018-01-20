defmodule ExTermbox.Renderer.Panel do
  alias ExTermbox.Position
  alias ExTermbox.Renderer.{Box, Canvas, Utils}

  def render(%Canvas{box: box, cells: cells} = canvas, title) do
    canvas
    |> Canvas.padded(1)
    |> Utils.render_border()
    |> render_title(title)
    |> Canvas.padded(1)
  end

  defp render_title(%Canvas{box: box} = canvas, title) do
    canvas
    |> Utils.render_text(title_position(box), title)
  end

  defp title_position(box), do: Position.translate_x(box.top_left, 2)
end
