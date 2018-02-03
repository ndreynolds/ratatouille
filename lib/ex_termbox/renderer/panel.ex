defmodule ExTermbox.Renderer.Panel do
  @moduledoc false

  alias ExTermbox.Position
  alias ExTermbox.Renderer.{Border, Canvas, Text}

  def render(%Canvas{} = canvas, title, inner_fn) do
    canvas
    |> Canvas.padded(1)
    |> Border.render()
    |> render_title(title)
    |> Canvas.padded(1)
    |> inner_fn.()
    |> Canvas.padded(-2)
  end

  defp render_title(%Canvas{box: box} = canvas, title) do
    canvas
    |> Text.render(title_position(box), title)
  end

  defp title_position(box), do: Position.translate_x(box.top_left, 2)
end
