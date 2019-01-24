defmodule Ratatouille.Renderer.Element.Label do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias Ratatouille.Renderer.{Canvas, Element, Text}

  def render(
        %Canvas{} = canvas,
        %Element{attributes: %{content: text}},
        _render_fn
      ) do
    canvas
    |> Text.render(canvas.render_box.top_left, text)
    |> Canvas.consume_rows(1)
  end

  def render(%Canvas{} = canvas, %Element{children: children}, _render_fn) do
    Text.render_group(canvas, children)
  end
end
