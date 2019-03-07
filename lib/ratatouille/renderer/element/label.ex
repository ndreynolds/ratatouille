defmodule Ratatouille.Renderer.Element.Label do
  @moduledoc false
  @behaviour Ratatouille.Renderer

  alias Ratatouille.Renderer.{Canvas, Element, Text}

  def render(
        %Canvas{} = canvas,
        %Element{attributes: %{content: text} = attrs},
        _render_fn
      ) do
    canvas
    |> Text.render(canvas.render_box.top_left, text, attrs)
    |> Canvas.consume_rows(1)
  end

  def render(
        %Canvas{} = canvas,
        %Element{attributes: attrs, children: children},
        _render_fn
      ) do
    canvas
    |> Text.render_group(children, attrs)
    |> Canvas.consume_rows(1)
  end
end
